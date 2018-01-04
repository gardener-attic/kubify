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


data "template_file" "cloud_conf" {
  template = "${file("${path.module}/templates/cloud.conf")}"

  vars {
    az_client_id = "${module.azure.client_id}"
    az_client_secret = "${module.azure.client_secret}"
    az_region = "${module.azure.region}"
    az_tenant_id = "${module.azure.tenant_id}"
    az_subscription_id = "${module.azure.subscription_id}"
    az_cloudenv = "${module.azure.cloudenv}"
    az_resource_group_name = "${azurerm_resource_group.rg.name}"
    az_vnet_name = "${azurerm_virtual_network.vnet.name}"
    az_subnet_name = "${azurerm_subnet.subnet.name}"
    az_security_group_name = "${azurerm_network_security_group.nodes.name}"
    az_route_table_name = "${azurerm_route_table.pods.name}"
    az_availability_set_name = "${azurerm_availability_set.primary.name}"
  }
}

resource "local_file" "cloud_conf" {
  content = "${data.template_file.cloud_conf.rendered}"
  filename = "${var.gen_dir}/iaas/cloud.conf"
}


output "cloud_conf" {
  value = "${data.template_file.cloud_conf.rendered}"
}

