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

variable "map" {
  type = "map"
}
variable "key" {
}
variable "value" {
  default = {}
}
variable "default" {
  default = {}
}

#
# terraform lookup does not support map values
# which is supported by the [] operator for a map,
# but this one alway yields an error, if the key does not exist.
#
# Therefore we simulate it by adding an implicit default to
# the map prior to indexing
# 

locals {
  def = {
    "${var.key}" = "${var.default}"
  }

  #
  # the ? operator does not work on lists or maps
  # to optionally use a map value we merge a map with the optional enforcement
  # value set (here local.def) for the requested key with an map
  # containing the optiobal value.
  # if the value is not set (empty map) just another key than the requested
  # one is used to create the merge map. Then the merge result for the
  # key falls back to the entry in the given map or the default.
  # The final result then is just the lookup of the requested key
  # in the merged map.
  #
  enforce = {
    "${length(var.value)>0 ? var.key : "<dummy>"}" = "${var.value}"
  }

  map = "${merge(local.def,var.map,local.enforce)}"
  value = "${local.map[var.key]}"
}

output "value" {
  value = "${local.value}"
}

