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

variable "path" {
  type = "string"
}

variable "default" {
  default = ""
}

variable "prefix" {
  default = ""
}

variable "suffix" {
  default = ""
}

variable "indent" {
  default = 0
}

module "content" {
  source  = "../variable"
  value   = "${file(var.path == "" ? "${path.module}/resources/empty" : var.path)}"
  default = "${var.default}"
}

locals {
  content = "${module.content.value == "" ? "" : "${var.prefix}${module.content.value}${var.suffix}"}"
}

output "content" {
  value = "${local.content}"
}

output "b64" {
  value = "${module.content.b64}"
}

output "indented" {
  value = "${indent(var.indent,local.content)}"
}
