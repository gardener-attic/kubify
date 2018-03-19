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
variable "border" {
}

variable "trailing" {
}
variable "leading" {
}

module "trailing" {
  source = "../../variable"
  value = "${length(var.trailing) > 0? var.trailing : var.leading}"
}

module "trailing_hash" {
  source = "../../variable"
  value = "${md5(module.trailing.value)}"
}
module "leading_hash" {
  source = "../../variable"
  value = "${md5(var.leading)}"
}

module "attr" {
  source = "../simple_attr"

  size = "${var.size}"
  border = "${var.border}"
  leading = "${module.leading_hash.value}"
  trailing = "${module.trailing_hash.value}"
}

output "info" {
  value = "${module.attr.info}"
}

output "active" {
  value = "${module.attr.active}"
}

output "leading" {
  value = "${var.leading}"
}
output "trailing" {
  value = "${module.trailing.value}"
}

output "map" {
  value = "${merge(map(module.leading_hash.value,var.leading),map(module.trailing_hash.value,module.trailing.value))}"
}

output "list" {
  value = "${module.attr.list}"
}
