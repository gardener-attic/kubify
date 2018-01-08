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


variable "values" {
  type = "list"
}

variable "buddies" {
  type = "list"
}

variable "message" {
  type = "string"
  default = "no configuration option selected"
}

locals {
  tmp = "${format("%*s",0+length(var.values)-length(var.buddies),"")}"
  trailing = "${split(" ",local.tmp)}"
  nonempty = "${compact(var.values)}"
  index = "${index(var.values,local.nonempty[0])}"
  # terraform does not suuport explicit error messages, so use a workaround
  # accessing a map generates an error if no entry can be found, 
  # the error message contains the key, which is set to the intended
  # error message
  key = "${length(local.nonempty) > 0 ? "found" : var.message}"
  map = "${map("found", "found")}"
  checked = "${local.map[local.key]}"
}

output "values" {
  value = "${var.values}"
}
output "index" {
  value = "${local.index}"
}
output "value" {
  value = "${element(concat(var.values,list("")),local.index)}"
}
output "buddy" {
  value = "${element(concat(var.buddies,local.trailing),local.index)}"
}
