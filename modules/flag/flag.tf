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


variable "option" {
  type = "string"
  default = "off"
}

variable "on" {
  type = "string"
  default = "true"
}

variable "off" {
  type = "string"
  default = "false"
}

variable "map" {
  type = "map"
  default = {}
}

module "values" {
  source = "../mapvar"

  value = "${merge(var.map, map("true", var.on, "1", var.on, "yes", var.on, "false", var.off, "0", var.off, "no", var.off))}"
}

output "value" {
  value = "${lookup(module.values.value, var.option)}"
}

output "flag" {
  value = "${lookup(module.values.value, var.option) == var.on ? 1 : 0}"
}

output "if_active" {
  value = "${lookup(module.values.value, var.option) == var.on ? 1 : 0}"
}
output "if_not_active" {
  value = "${lookup(module.values.value, var.option) == var.on ? 0 : 1}"
}
