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

module "lbaas_pool" {
  source = "../../../../modules/flag"
  option = "${signum(length(module.os.lbaas_pool_name))}"
}
module "lbaas_subnet" {
  source = "../../../../modules/flag"
  option = "${signum(length(module.os.lbaas_subnet_id))}"
}
module "subnet_cidr" {
  source = "../../../../modules/variable"
  value = "${var.subnet_cidr}"
  default = "192.168.100.0/24"
}
module "device_name" {
  source = "../../../../modules/variable"
  value = "${module.os.device_name}"
  default = "/dev/vdb"
}

data "openstack_networking_network_v2" "fip" {
  name = "${module.os.fip_pool_name}"
}

resource "openstack_networking_router_v2" "cluster" {
  name             = "${var.prefix}"
  external_gateway = "${data.openstack_networking_network_v2.fip.id}"
  region           = "${module.os.region}"
}

resource "openstack_networking_network_v2" "cluster" {
  name           = "${var.prefix}"
  admin_state_up = "true"
}

resource "openstack_networking_subnet_v2" "cluster" {
  name       = "${var.prefix}"
  network_id = "${openstack_networking_network_v2.cluster.id}"
  cidr       = "${module.subnet_cidr.value}"
  ip_version = 4
  dns_nameservers = "${var.dns_nameservers}"
}

resource "openstack_networking_router_interface_v2" "router_nodes" {
  router_id = "${openstack_networking_router_v2.cluster.id}"
  subnet_id = "${openstack_networking_subnet_v2.cluster.id}"
}

resource "openstack_networking_secgroup_v2" "cluster" {
  name        = "${var.prefix}"
  description = "Cluster Nodes"
  delete_default_rules = true
}

resource "openstack_networking_secgroup_rule_v2" "cluster_self" {
  direction         = "ingress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.cluster.id}"
  remote_group_id   = "${openstack_networking_secgroup_v2.cluster.id}"
}

resource "openstack_networking_secgroup_rule_v2" "cluster_egress" {
  direction         = "egress"
  ethertype         = "IPv4"
  security_group_id = "${openstack_networking_secgroup_v2.cluster.id}"
}

# resource "openstack_networking_secgroup_rule_v2" "cluster_lbaas" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   remote_ip_prefix  = "${var.lbaas_subnet_cidr}"
#   security_group_id = "${openstack_networking_secgroup_v2.cluster.id}"
# }

# resource "openstack_networking_secgroup_rule_v2" "cluster_ssh" {
#   direction         = "ingress"
#   ethertype         = "IPv4"
#   protocol          = "tcp"
#   port_range_min    = 22
#   port_range_max    = 22
#   remote_ip_prefix  = "0.0.0.0/0"
#   security_group_id = "${openstack_networking_secgroup_v2.cluster.id}"
# }

resource "openstack_networking_secgroup_rule_v2" "cluster_tcp_all" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 1
  port_range_max    = 65535
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = "${openstack_networking_secgroup_v2.cluster.id}"
}

resource "openstack_compute_servergroup_v2" "nodes" {
  name     = "${var.prefix}-servergroup"
  policies = ["anti-affinity"]
}

module "iaas_info" {
  source = "../../../../modules/mapvar"
  value = {
    network_id        = "${openstack_networking_network_v2.cluster.id}"
    server_group_id   = "${openstack_compute_servergroup_v2.nodes.id}"
  }
}

output "iaas_info" {
  value = "${module.iaas_info.value}"
}
output "subnet_id" {
  value = "${openstack_networking_subnet_v2.cluster.id}"
}
output "security_group_id" {
  value = "${openstack_networking_secgroup_v2.cluster.id}"
}
output "security_group" {
  value = "${openstack_networking_secgroup_v2.cluster.name}"
}

output "default_user" {
  value = "${module.os.user_name}"
}
output "default_password" {
  value = "${module.os.password}"
}

output "device" {
  value = "${module.device_name.value}"
}
output "cloud_provider" {
  value = "openstack"
}
