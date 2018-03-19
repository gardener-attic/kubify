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


variable "platform" {
  type = "string"
}

variable "node_type" {
  type = "string"
}

variable "default_image_name" {
  type = "string"
}
variable "image_name" {
  type = "string"
}

variable "default_flavor_name" {
  type = "string"
}
variable "flavor_name" {
  type = "string"
}

locals {
  struct = {
    "${var.node_type}" = {}
  }
  defaulted_image_versions = "${merge(local.struct,local.image_versions)}"
  platform_image_versions = "${local.defaulted_image_versions[var.platform]}"

  defaulted_flavor_names = "${merge(local.struct,local.flavor_names)}"
  platform_flavor_names = "${local.defaulted_flavor_names[var.platform]}"
}

module "default_image_name" {
  source = "../map"
  value = "${var.default_image_name}"
  map = "${local.platform_image_versions}"
}
module "image_name" {
  source = "../map"
  value = "${var.image_name}"
  default = "${module.default_image_name.value}"
  map = "${local.platform_image_versions}"
}

module "default_flavor_name" {
  source = "../variable"
  value = "${lookup(local.platform_flavor_names, "default", "")}"
}
module "default_type_flavor_name" {
  source = "../variable"
  value = "${lookup(local.platform_flavor_names, var.node_type, "")}"
  default = "${module.default_flavor_name.value}"
}
module "flavor_name" {
  source = "../defaults"
  values = [ "${var.flavor_name}", "${var.default_flavor_name}", "${module.default_type_flavor_name.value}" ]
}

output "platform" {
  value = "${var.platform}"
}
output "flavors" {
  value = "${local.platform_flavor_names}"
}
output "images" {
  value = "${local.platform_image_versions}"
}

output "flavor_name" {
  value = "${module.flavor_name.value}"
}
output "image_name" {
  value = "${module.image_name.value}"
}

