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


variable "value" {
  type = "string"
}

variable "values" {
  type = "list"
}

locals {
#  map = "${transpose(map(var.value,var.values))}"
  value = "${var.value}"
  key = "${contains(var.values, local.value) ? local.value : "invalid value"}"
  map = "${map(local.key, local.value)}"
  checked = "${local.map[local.value]}"
}

output "value" {
  value = "${local.checked}"
}
