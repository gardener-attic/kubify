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


##########################################
# public ips
#

module "fips" {
  source = "../../../../modules/flag"
  option = "${var.provide_fips}"
  on = "${var.node_count}"
  off = "0"
  map = {
    single = "1"
  }
}

resource "azurerm_public_ip" "nodes" {
  count                        = "${module.fips.value}"
  name                         = "${var.prefix}-${var.node_type}-${count.index}"
  location                     = "${module.azure.region}"
  resource_group_name          = "${module.resource_group_name.value}"
  public_ip_address_allocation = "Static"
}

locals {
  ip_config = {
    subnet_id                               = "${var.subnet_id}"
    private_ip_address_allocation           = "dynamic"
  }

  #
  # * ip config with an empty list for load_balancer_backend_address_pools_ids does not work
  #    so, we habe to provide map with or without the field to avoid multiple counted resource
  #    definitions because of the load balancer
  # * conditional expression does not wirk for map results in terraform
  #    so we have to use the conditional expression to switch the key (string) to a value
  #    (subnet_id) that is merged (overwritten) later with an other value.
  #    This discards the load_balancer_backend_address_pools_ids entry
  ip_configuration = "${merge(map(length(module.lbaas.pool_ids)>0?"load_balancer_backend_address_pools_ids":"subnet_id",module.lbaas.pool_ids), local.ip_config)}"
}
output "ip_config" {
  value = "${local.ip_configuration}"
}

resource "azurerm_network_interface" "fip-nic" {
  count                = "${module.fips.value}"
  name                 = "${var.prefix}-${var.node_type}-${count.index}-nic"
  location             = "${module.azure.region}"
  enable_ip_forwarding = "true"
  resource_group_name  = "${module.resource_group_name.value}"
  network_security_group_id = "${var.security_group}"

  ip_configuration {
    name                                    = "${var.prefix}-${var.node_type}-${count.index}-ip-conf"
    subnet_id                               = "${var.subnet_id}"
    private_ip_address_allocation           = "dynamic"
    public_ip_address_id                    = "${element(azurerm_public_ip.nodes.*.id,count.index)}"
    load_balancer_backend_address_pools_ids = ["${module.lbaas.pool_id}"]
  }
}

resource "azurerm_network_interface" "nofip-nic" {
  count                = "${var.node_count - module.fips.value}"
  name                 = "${var.prefix}-${var.node_type}-${module.fips.value + count.index}-nic"
  location             = "${module.azure.region}"
  enable_ip_forwarding = "true"
  resource_group_name  = "${module.resource_group_name.value}"
  network_security_group_id = "${var.security_group}"

  #ip_configuration = ["${merge(local.ip_configuration,map("name","${var.prefix}-${var.node_type}-${count.index}-ip-conf"))}"]
  #ip_configuration = ["${map("subnet_id", "${var.subnet_id}", "name","${var.prefix}-${var.node_type}-${count.index}-ip-conf")}"]
  ip_configuration {
    name                                    = "${var.prefix}-${var.node_type}-${count.index}-ip-conf"
    subnet_id                               = "${var.subnet_id}"
    private_ip_address_allocation           = "dynamic"
    load_balancer_backend_address_pools_ids = ["${module.lbaas.pool_id}"]
  }
}

module "nics" {
  source = "../../../../modules/listvar"
  value = "${concat(azurerm_network_interface.fip-nic.*.id, azurerm_network_interface.nofip-nic.*.id)}"
}

module "ips" {
  source = "../../../../modules/listvar"
  value = "${concat(azurerm_network_interface.fip-nic.*.private_ip_address, azurerm_network_interface.nofip-nic.*.private_ip_address)}"
}

output "fips" {
  value = ["${azurerm_public_ip.nodes.*.ip_address}"]
} 
