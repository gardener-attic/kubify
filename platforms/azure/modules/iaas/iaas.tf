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


module "azure" {
  source = "../config"
  iaas_config = "${var.iaas_config}"
}

module "subnet_cidr" {
  source = "../../../../modules/variable"
  value = "${var.subnet_cidr}"
  default = "192.168.100.0/24"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}"
  location = "${module.azure.region}"
}

#=====================================================================
#= VNET, Subnets, Route Table, Security Groups
#=====================================================================
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${module.azure.region}"
  address_space       = ["${module.subnet_cidr.value}"]
}

resource "azurerm_route_table" "pods" {
  name                = "${var.prefix}-pods"
  location            = "${module.azure.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_network_security_group" "subnet" {
  name                      = "${var.prefix}-subnet"
  location                  = "${module.azure.region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "nodes" {
  name                = "${var.prefix}-nodes"
  location            = "${module.azure.region}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "subnet" {
  name                      = "${var.prefix}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  virtual_network_name      = "${azurerm_virtual_network.vnet.name}"
  address_prefix            = "${module.subnet_cidr.value}"
  route_table_id            = "${azurerm_route_table.pods.id}"
  network_security_group_id = "${azurerm_network_security_group.subnet.id}"
}

resource "azurerm_network_security_group" "bastion" {
  name                      = "${var.prefix}-bastion"
  location                  = "${module.azure.region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_availability_set" "primary" {
  name                      = "${var.prefix}-primary"
  location                  = "${module.azure.region}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  managed                   = true
}

module "iaas_info" {
  source = "../../../../modules/mapvar"
  value = {
    resource_group_name = "${azurerm_resource_group.rg.name}"
    vnet_name = "${azurerm_virtual_network.vnet.name}"
    subnet_name = "${azurerm_subnet.subnet.name}"
  }
}

output "iaas_info" {
  value = "${module.iaas_info.value}"
}
output "subnet_id" {
  value = "${azurerm_subnet.subnet.id}"
}
output "nodes_cidr" {
  value = "${module.subnet_cidr.value}"
}
output "security_group_id" {
  value = "${azurerm_network_security_group.nodes.id}"
}
output "security_group" {
  value = "${azurerm_network_security_group.nodes.id}"
}


output "default_user" {
  value = "${module.azure.client_id}"
}

output "default_password" {
  value = "${module.azure.client_secret}"
}

output "device" {
  value = "/dev/sdc"
}
output "cloud_provider" {
  value = "azure"
}


