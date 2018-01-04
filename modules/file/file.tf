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


variable "path" {
  type = "string"
}

variable "default" {
  default = ""
}

module "content" {
  source = "../variable"
  value = "${file(var.path == "" ? "${path.module}/resources/empty" : var.path)}"
  default = "${var.default}"
}

output "content" {
  value = "${module.content.value}"
}
output "b64" {
  value = "${module.content.b64}"
}
