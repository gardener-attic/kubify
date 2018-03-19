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
#
# if config specifies a lbaas_subnet_id, the lbaas should be created there (not possible with haproxy)
# if an lbaas_pool_name is specified, fips have to be used. Then either the member subnet or
# a dedicated lbaas subnet provided by the iaas module (not yet implemented) should be used.
#
module "lbaas_subnet_id" {
  source = "../../../../modules/variable"
  value = "${module.os.lbaas_subnet_id}"
  default ="${lookup(var.iaas_info, "lbaas_subnet_id","")}"
}
module "lbaas_pool_name" {
  source = "../../../../modules/variable"
  value = "${module.os.lbaas_pool_name}"
  default = "${module.os.lbaas_subnet_id == "" ? module.os.fip_pool_name : ""}"
}

module "lbaas" {
  source = "../lbaas"

  name = "${var.prefix}-${module.lbaas_name.value}"
  description = "${var.lbaas_description}"
  provider = "${module.os.lbaas_provider}"
  ports = "${var.lbaas_ports}"

  vip_subnet_id = "${module.lbaas_subnet_id.value}"
  vip_pool_name = "${module.lbaas_pool_name.value}"
  member_count = "${var.node_count}"
  member_subnet_id = "${var.subnet_id}"
  members = "${module.ips.value}"
 
  use_lbaas = "${var.provide_lbaas}"
}

output "lbaas_address" {
  value = "${module.lbaas.vip_address}"
}
output "lbaas_address_type" {
  value = "${module.lbaas.vip_type}"
}
