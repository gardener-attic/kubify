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

variable "size" {
}
variable "leading" {
  type = "string"
}
variable "trailing" {
  type = "string"
}
variable "border" {
}

module "l_leading" {
  source = "../../variable"
  value = "${format("%*s",0+var.border,"")}"
}
module "l_trailing" {
  source = "../../variable"
  value = "${format("%*s",0+var.size - var.border,"")}"
}
module "p_leading" {
  source = "../../variable"
  value = "${replace(module.l_leading.value, " ","${var.leading},")}"
}
module "p_trailing" {
  source = "../../variable"
  value = "${replace(module.l_trailing.value, " ","${var.trailing},")}"
}
output "list" {
  value = "${compact(split(",", "${module.p_leading.value}${module.p_trailing.value}"))}"
}
