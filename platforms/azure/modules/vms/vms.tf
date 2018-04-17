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


module "azure" {
  source = "../config"
  iaas_config = "${var.iaas_config}"
}

module "resource_group_name" {
  source = "../../../../modules/variable"
  value  = "${lookup(var.iaas_info,"resource_group_name")}"
}

module "storage" {
  source = "../../../../modules/variable"
  value = "${var.provide_storage ? 1 : 0}"
}


resource "azurerm_availability_set" "nodes" {
  name                      = "${var.prefix}-${var.node_type}"
  location                  = "${module.azure.region}"
  resource_group_name       = "${module.resource_group_name.value}"
  managed                   = true
}


resource "azurerm_managed_disk" "data" {
  count                 = "${module.storage.value * var.node_count}"
  name                  = "${var.prefix}-${var.node_type}-${count.index}-data-disk-${var.vm_version}"
  resource_group_name   = "${module.resource_group_name.value}"
  location              = "${module.azure.region}"
  storage_account_type  = "Premium_LRS"
  create_option         = "Empty"
  disk_size_gb          = "${var.volume_size}"
}

locals {
  separator = "/"
  tags = {
    "Cluster" = "${var.cluster_name}"
    "Role"    = "${var.node_type}"
  }
}

resource "azurerm_virtual_machine" "storage" {
  # changing cloud init does not enforce vm recreation
  # therefore we use the revision here to extend the name
  count                 = "${module.storage.value * var.node_count}"
  name                  = "${var.prefix}-${var.node_type}-${count.index}-${var.vm_version + element(module.roll.revision_list,count.index)}"
  location              = "${module.azure.region}"
  resource_group_name   = "${module.resource_group_name.value}"
  network_interface_ids = ["${element(module.nics.value, count.index)}"]
  vm_size               = "${element(module.roll.flavor_list, count.index)}"
  availability_set_id   = "${azurerm_availability_set.nodes.id}"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "${element(split("${local.separator}",element(module.roll.image_list, count.index)),0)}"
    offer = "${element(split("${local.separator}",element(module.roll.image_list, count.index)),1)}"
    sku = "${element(split("${local.separator}",element(module.roll.image_list, count.index)),2)}"
    version = "${element(split("${local.separator}",element(module.roll.image_list, count.index)),3)}"
  }

  storage_os_disk {
    name          = "${var.prefix}-${var.node_type}-${count.index}-os-disk"
    managed_disk_type = "Standard_LRS"
    caching       = "None"
    create_option = "FromImage"
    disk_size_gb  = "${var.root_volume_size}"
  }

  storage_data_disk {
    name          = "${var.prefix}-${var.node_type}-${count.index}-data-disk-${var.vm_version}"
    create_option = "Attach"
    managed_disk_id = "${element(azurerm_managed_disk.data.*.id,count.index)}"
    caching       = "None"
    disk_size_gb  = "${var.volume_size}"
    lun           = 0
  }

  tags = "${merge(local.tags,map("Name","${var.prefix}-${var.node_type}-${count.index}-${var.vm_version + element(module.roll.revision_list,count.index)}"))}"

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = [{
      path = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${var.key}"
    }]
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.node_type}-${count.index}-${var.vm_version + element(module.roll.revision_list,count.index)}"
    admin_username = "${var.admin_user}"
    custom_data    = "${lookup(module.roll.cloud_init_map,element(module.roll.cloud_init_list,count.index))}"
  }
}

resource "azurerm_virtual_machine" "nostorage" {
  count                 = "${(1 - module.storage.value) * var.node_count}"
  name                  = "${var.prefix}-${var.node_type}-${count.index}-${var.vm_version + element(module.roll.revision_list,count.index)}"
  location              = "${module.azure.region}"
  resource_group_name   = "${module.resource_group_name.value}"
  network_interface_ids = ["${element(module.nics.value, count.index)}"]
  vm_size               = "${element(module.roll.flavor_list, count.index)}"
  availability_set_id   = "${azurerm_availability_set.nodes.id}"

  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "${element(split("${local.separator}",element(module.roll.image_list, count.index)),0)}"
    offer = "${element(split("${local.separator}",element(module.roll.image_list, count.index)),1)}"
    sku = "${element(split("${local.separator}",element(module.roll.image_list, count.index)),2)}"
    version = "${element(split("${local.separator}",element(module.roll.image_list, count.index)),3)}"
  }

  storage_os_disk {
    name          = "${var.prefix}-${var.node_type}-${count.index}-os-disk"
    managed_disk_type = "Standard_LRS"
    caching       = "None"
    create_option = "FromImage"
    disk_size_gb  = "${var.root_volume_size}"
  }

  tags = "${merge(local.tags,map("Name","${var.prefix}-${var.node_type}-${count.index}-${var.vm_version + element(module.roll.revision_list,count.index)}"))}"

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys = [{
      path = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = "${var.key}"
    }]
  }

  os_profile {
    computer_name  = "${var.prefix}-${var.node_type}-${count.index}-${var.vm_version + element(module.roll.revision_list,count.index)}"
    admin_username = "${var.admin_user}"
    custom_data =  "${lookup(module.roll.cloud_init_map,element(module.roll.cloud_init_list,count.index))}"
  }
}

module "nodes" {
  source = "../../../../modules/listvar"
  value = "${concat(azurerm_virtual_machine.storage.*.id, azurerm_virtual_machine.nostorage.*.id)}"
}  

output "ids" {
  value = ["${module.nodes.value}"]
}
output "ips" {
  value = ["${module.ips.value}"]
}

output "disk_vm_ips" {
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
    image = "${var.image_name}"
    subnet_name  = "${lookup(var.iaas_info,"subnet_name")}"
    vnet_name  = "${lookup(var.iaas_info,"vnet_name")}"
    public_key = "${var.key}"

    resource_group = "${module.resource_group_name.value}"
    availability_set = "${azurerm_availability_set.nodes.id}}"
    admin_user = "${var.admin_user}"

    security_group = "${var.security_group}"
    root_volume_size = "${var.root_volume_size}"
    tags = "${jsonencode(local.tags)}"
  }
}
