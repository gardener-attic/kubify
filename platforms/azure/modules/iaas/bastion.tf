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


module "bastion" {
  source = "../vms"

  iaas_config       = "${var.iaas_config}"
  iaas_info         = "${module.iaas_info.value}"
  prefix            = "${var.prefix}"

  cluster_name      = "${var.cluster_name}"
  cluster_type      = "${var.cluster_type}"
  node_type         = "bastion"
  node_count        = "${var.use_bastion ? 1 : 0}"

  image_name        = "${var.bastion_image_name}"
  flavor_name       = "${var.bastion_flavor_name}"

  key               = "${tls_private_key.ssh_key.public_key_openssh}"

  subnet_id         = "${azurerm_subnet.subnet.id}"
  security_group    = "${azurerm_network_security_group.bastion.id}"

  admin_user        = "${var.bastion_user}"
  provide_fips      = true
}

output "bastion_id" {
  value = "${element(concat(module.bastion.ids,list("")),0)}"
}

output "bastion_ip" {
  value = "${element(concat(module.bastion.ips,list("")),0)}"
}

output "bastion" {
  value = "${element(concat(module.bastion.fips,list("")),0)}"
}

