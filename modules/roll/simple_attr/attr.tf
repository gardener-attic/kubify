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


variable "size" {
}
variable "border" {
}
variable "trailing" {
}
variable "leading" {
}

module "active" {
  source = "../../variable"
  value = "${var.leading != module.trailing.value ? 1 : 0}"
}

module "trailing" {
  source = "../../variable"
  value = "${length(var.trailing) > 0? var.trailing : var.leading}"
}

module "list" {
  source = "../list"
  size = "${var.size}"
  border = "${var.border}"
  trailing = "${module.trailing.value}"
  leading = "${var.leading}"
}

output "info" {
  value = {
    active = "${module.active.value}"
    list = "${module.list.list}"
  }
}

output "active" {
  value = "${module.active.value}"
}
output "list" {
  value = "${module.list.list}"
}
output "leading" {
  value = "${var.leading}"
}
output "trailing" {
  value = "${module.trailing.value}"
}
