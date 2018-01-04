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

module "lbaas_name" {
  source = "../../../../modules/variable"
  value = "${var.lbaas_name}"
  default = "${var.node_type}"
}

module "lbaas_subnet_id" {
  source = "../../../../modules/variable"
  value ="${lookup(var.iaas_info, "public_subnet_id","")}"
}

module "lbaas" {
  source = "../lbaas"

  vpc_id ="${lookup(var.iaas_info, "vpc_id")}"
  name = "${var.prefix}-${module.lbaas_name.value}"
  description = "${var.lbaas_description}"
  ports = "${var.lbaas_ports}"

  security_groups = [ "${var.security_group}", "${lookup(var.iaas_info,"secgrp_public")}" ]
  vip_subnet_id = "${module.lbaas_subnet_id.value}"
  member_count = "${var.node_count}"
  member_subnet_id = "${var.subnet_id}"
  members = "${module.nodes.value}"
 
  use_lbaas = "${var.provide_lbaas}"
}

output "lbaas_address" {
  value = "${module.lbaas.vip_address}"
}
output "lbaas_address_type" {
  value = "${module.lbaas.vip_type}"
}
