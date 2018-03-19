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

variable "permissions" {
  default = "0644"
}

variable "content" {
  default = ""
}

variable "omit_empty" {
  default = false
}

data "template_file" "entry" {
  template = "${file("${path.module}/templates/path")}"

  vars {
    path = "${var.path}"
    permissions = "${var.permissions}"
    content = "${base64encode(var.content)}"
  }
}

locals {
  entry = "${var.content == "" && var.omit_empty ? "" : data.template_file.entry.rendered}"
}

output "entry" {
  value = "${local.entry}"
}

output "if_active" {
  value = "${length(local.entry) > 0 ? 1 : 0}"
}
output "if_not_active" {
  value = "${length(local.entry) == 0 ? 1 : 0}"
}

