# Copyright (c) 2017 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
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

variable "use_lbaas" {
  default = "1"
}

variable "name" {
  type = "string"
}
variable "description" {
  default = ""
}
variable "region" {
}
variable "resource_group_name" {
}


variable "ports" {
  type = "list"
  default = [ "443" ]
}

module "lbaas" {
  source = "../../../../modules/flag"
  option = "${var.use_lbaas}"
}


resource "azurerm_public_ip" "lb" {
  count                        = "${module.lbaas.flag}"
  name                         = "${var.name}"
  location                     = "${var.region}"
  resource_group_name          = "${var.resource_group_name}"
  public_ip_address_allocation = "Static"
}

resource "azurerm_lb" "lb" {
  count                        = "${module.lbaas.flag}"
  name                         = "${var.name}"
  location                     = "${var.region}"
  resource_group_name          = "${var.resource_group_name}"

  frontend_ip_configuration {
    name                       = "${var.name}"
    public_ip_address_id       = "${azurerm_public_ip.lb.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb" {
  count                        = "${module.lbaas.flag}"
  name                         = "${var.name}"
  loadbalancer_id              = "${azurerm_lb.lb.id}"
  resource_group_name          = "${var.resource_group_name}"
}

resource "azurerm_lb_rule" "lb" {
  count                        = "${length(var.ports) * module.lbaas.flag}"
  name                         = "${var.name}-${element(var.ports,count.index)}"
  loadbalancer_id              = "${azurerm_lb.lb.id}"
  frontend_ip_configuration_name = "${var.name}"
  protocol                     = "Tcp"
  frontend_port                = "${element(var.ports,count.index)}"
  backend_port                 = "${element(var.ports,count.index)}"
  backend_address_pool_id      = "${azurerm_lb_backend_address_pool.lb.id}"
  probe_id                     = "${element(azurerm_lb_probe.lb.*.id,count.index)}"
  resource_group_name          = "${var.resource_group_name}"
}

resource "azurerm_lb_probe" "lb" {
  count                        = "${length(var.ports) * module.lbaas.flag}"
  name                         = "${var.name}-${element(var.ports,count.index)}"
  resource_group_name          = "${var.resource_group_name}"
  loadbalancer_id              = "${azurerm_lb.lb.id}"
  port                         = "${element(var.ports,0)}"
  protocol                     = "Tcp"
  interval_in_seconds          = 20
  number_of_probes             = 2
}

output "vip_address" {
  value = "${azurerm_public_ip.lb.*.ip_address}"
}
output "vip_type" {
  value = "A"
}

locals {
  pool_ids = "${compact(concat(azurerm_lb_backend_address_pool.lb.*.id,list("")))}"
}
output "pool_id" {
  value = "${azurerm_lb_backend_address_pool.lb.*.id}"
}
output "pool_ids" {
  value = "${local.pool_ids}"
}

