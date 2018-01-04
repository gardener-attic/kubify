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
  default = ""
}

variable "default" {
  default = ""
}

variable "defaults" {
  default = [ ]
}

variable "optional" {
  default=false
}

locals {
  options = {
    optional = [ "" ]
    required = []
  }
  value = "${element(concat(compact(concat(list(var.value, var.default),var.defaults)),local.options[var.optional ? "optional" : "required"]),0)}"
}

output "value" {
  value = "${local.value}"
}

output "configured" {
  value = "${var.value}"
}

output "b64" {
  value = "${base64encode(local.value)}"
}

output "if_configured" {
  value = "${(length(var.value) > 0) ? 1 : 0}"
}

output "if_not_configured" {
  value = "${(length(var.value) == 0) ? 1 : 0}"
}

output "if_defaulted" {
  value = "${(length(var.value) == 0) ? 1 : 0}"
}

output "if_set" {
  value = "${(length(local.value) > 0) ? 1 : 0}"
}

output "if_noset" {
  value = "${(length(local.value) == 0) ? 1 : 0}"
}

