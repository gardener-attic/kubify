# Copyright 2017 The Gardener Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


module "os" {
  source = "../config"
  iaas_config = "${var.iaas_config}"
}

data "openstack_images_image_v2" "image" {
  name        = "${var.image_name}"
  most_recent = true
}

output "image_name" {
  value  = "${var.image_name}"
}

module "storage" {
  source = "../../../../modules/variable"
  value = "${var.provide_storage ? 1 : 0}"
}

locals {
  toggle="${var.vm_version % 2}"
}
resource "openstack_blockstorage_volume_v2" "nodes" {
  count       = "${module.storage.value * var.node_count}"
  name        = "${var.prefix}-${var.node_type}-${count.index}"
  size        = "${var.volume_size + local.toggle}"
  availability_zone = "${module.os.volume_zone}"
}
locals {
  volumes = "${openstack_blockstorage_volume_v2.nodes.*.id}"
}

##########################################
# nodes
#

module "tags" {
  source = "../../../../modules/mapvar"
  value = {
      clustername = "${var.cluster_name}"
      clustertype = "${var.cluster_type}"
      kind        = "${var.node_type}"
  }
}

locals {
  tags = "${merge(module.tags.value)}"
}

resource "openstack_compute_instance_v2" "storage" {
  count           = "${module.storage.value * var.node_count}"
  name            = "${var.prefix}-${var.node_type}-${count.index}"
  flavor_name     = "${element(module.roll.flavor_list, count.index)}"
  image_id        = "${element(module.roll.image_list, count.index)}"
  key_pair        = "${var.key}"
  # not sure why name is working -> id forces change
  security_groups = ["${var.security_group}"]
  availability_zone = "${module.os.availability_zone}"
  force_delete = true

  scheduler_hints {
    group = "${lookup(var.iaas_info, "server_group_id")}"
  }

  metadata = "${merge(local.tags, map("Name", "${var.prefix}-${var.node_type}-${count.index}"))}"

  block_device {
    uuid                  = "${element(module.roll.image_list, count.index)}"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = "${var.root_volume_size}"
  }

  block_device {
    uuid                  = "${element(local.volumes,count.index)}"
    source_type           = "volume"
    destination_type      = "volume"
    boot_index            = 1
    delete_on_termination = false
  }


  network {
    uuid = "${lookup(var.iaas_info, "network_id")}"
  }

  user_data = "${lookup(module.roll.cloud_init_map,element(module.roll.cloud_init_list,count.index))}"
}

resource "openstack_compute_instance_v2" "nostorage" {
  count           = "${(1 - module.storage.value) * var.node_count}"
  name            = "${var.prefix}-${var.node_type}-${count.index}"
  flavor_name     = "${element(module.roll.flavor_list, count.index)}"
  image_id        = "${element(module.roll.image_list, count.index)}"
  key_pair        = "${var.key}"
  # not sure why name is working -> id forces change
  security_groups = ["${var.security_group}"]
  availability_zone = "${module.os.availability_zone}"
  force_delete = true

  scheduler_hints {
    group = "${lookup(var.iaas_info, "server_group_id")}"
  }

  metadata = "${merge(local.tags, map("Name", "${var.prefix}-${var.node_type}-${count.index}"))}"

  block_device {
    uuid                  = "${element(module.roll.image_list, count.index)}"
    source_type           = "image"
    destination_type      = "local"
    boot_index            = 0
    delete_on_termination = true
    volume_size           = "${var.root_volume_size}"
  }

  network {
    uuid = "${lookup(var.iaas_info, "network_id")}"
  }

  user_data = "${lookup(module.roll.cloud_init_map,element(module.roll.cloud_init_list,count.index))}"
}

module "nodes" {
  source = "../../../../modules/listvar"
  value = "${concat(openstack_compute_instance_v2.storage.*.id, openstack_compute_instance_v2.nostorage.*.id)}"
}

module "ips" {
  source = "../../../../modules/listvar"
  value = "${concat(openstack_compute_instance_v2.storage.*.network.0.fixed_ip_v4, openstack_compute_instance_v2.nostorage.*.network.0.fixed_ip_v4)}"
}

output "ids" {
  value = ["${module.nodes.value}"]
}
output "ips" {
  value = ["${module.ips.value}"]
}

output "count" {
  value = ["${var.node_count}"]
}
output "created" {
  value = ["${length(module.nodes.value)}"]
}
output "storage" {
  value = ["${module.storage.value}"]
}

output "short_user_data" {
  value = "false"
}


output "vm_info" {
  value = {
    cloud_init = "${var.cloud_init}"
    flavor = "${var.flavor_name}"
    keypair = "${var.key}"
    image = "${var.image_name}"
    networkid = "${lookup(var.iaas_info, "network_id")}"
    security_group = "${var.security_group}"
    tags = "${jsonencode(local.tags)}"
  }
}

