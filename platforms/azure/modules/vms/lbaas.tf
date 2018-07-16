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


module "lbaas_name" {
  source = "../../../../modules/variable"
  value = "${var.lbaas_name}"
  default = "${var.node_type}"
} 

module "lbaas" {
  source = "../lbaas"

  name = "${var.prefix}-${module.lbaas_name.value}"
  resource_group_name = "${module.resource_group_name.value}"
  region = "${module.azure.region}"
  description = "${var.lbaas_description}"
  ports = "${var.lbaas_ports}"
  
  use_lbaas = "${var.provide_lbaas}"
}

output "lbaas_address" {
  # forcing to pick first element
  value = "${length(module.lbaas.vip_address) > 0 ? element(concat(module.lbaas.vip_address, list("")), 0) : ""}"
}  
output "lbaas_address_type" {
  value = "${module.lbaas.vip_type}"
}  

