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
  default = 0
}
variable "state" {
  default = { }
}
variable "update_mode" {
  type = "string"
  default = "Roll"   # values are Roll, All or None
}

module "border" {
  source = "../variable"
  value = "${var.update_mode == "Roll" ? lookup(var.state,"next",var.border) : ( var.update_mode == "None" ? 0 : var.size ) }"
}

#############################################
# roll attributes
#
# all roll attributes modules MUST be added to the "active" module below

#
# image attribute
#
# simple identifier
# return a direct image list
#
variable "current_image_name" {
  default = ""
}
variable "image_name" {
}

module "image" {
  source = "simple_attr"

  size = "${var.size}"
  border = "${module.border.value}"
  leading = "${var.image_name}"
  trailing = "${lookup(var.state,"image_name",var.current_image_name)}"
}

output "image_name" {
  value = "${module.image.leading}"
}
output "current_image_name" {
  value = "${module.last_run.value ?  module.image.leading  : module.image.trailing}"
}
output "image_list" {
  value = "${module.image.list}"
}

#
# flavor attribute
#
# simple identifier
# return a direct flavor list
#
variable "current_flavor_name" {
  default = ""
}
variable "flavor_name" {
}

module "flavor" {
  source = "simple_attr"

  size = "${var.size}"
  border = "${module.border.value}"
  leading = "${var.flavor_name}"
  trailing = "${lookup(var.state,"flavor_name",var.current_flavor_name)}"
}

output "flavor_name" {
  value = "${module.flavor.leading}"
}
output "current_flavor_name" {
  value = "${module.last_run.value ?  module.flavor.leading  : module.flavor.trailing}"
}
output "flavor_list" {
  value = "${module.flavor.list}"
}

#
# cloud init attribute
#
# complex value
# return an id list and an id map for indirection
#
variable "current_cloud_init" {
  default = ""
}
variable "cloud_init" {
}

module "cloud_init" {
  source = "complex_attr"

  size = "${var.size}"
  border = "${module.border.value}"
  leading = "${var.cloud_init}"
  trailing = "${lookup(var.state,"cloud_init",var.current_cloud_init)}"
}

output "cloud_init" {
  value = "${module.cloud_init.leading}"
}
output "current_cloud_init" {
  value = "${module.last_run.value ?  module.cloud_init.leading  : module.cloud_init.trailing}"
}
output "cloud_init_list" {
  value = "${module.cloud_init.list}"
}
output "cloud_init_map" {
  value = "${module.cloud_init.map}"
}


#############################################
# roll revision

locals {
  revision="${lookup(var.state,"revision","0")}"
  delta = "${module.active.value}"
}

module "revision" {
  source = "simple_attr"

  size = "${var.size}"
  border = "${module.border.value}"
  leading = "${local.revision + local.delta}"
  trailing = "${local.revision}"
}

output "revision_list" {
  value = "${module.revision.list}"
}

#############################################
# roll state
#

#
# add all roll attributes here !!!!
#
module "required" {
  source = "../variable"
  value = "${signum(module.image.active + module.flavor.active + module.cloud_init.active)}"
}
module "active" {
  source = "../variable"
  value = "${var.update_mode != "None" ? module.required.value : 0}"
}

module "last_run" {
  source = "../variable"
  value = "${module.border.value == var.size && module.active.value ? 1 : 0}"
}
module "pending" {
  source = "../variable"
  value = "${module.active.value && !module.last_run.value}"
}
module "next" {
  source = "../variable"
  value = "${module.pending.value? ( module.border.value < var.size ? module.border.value + 1 : module.border.value ) : 1}"
}



output "state" {
  value = {
    pending = "${module.pending.value}"
    next = "${module.next.value}"
    flavor_name = "${module.last_run.value ?  module.flavor.leading  : module.flavor.trailing}"
    image_name = "${module.last_run.value ?  module.image.leading  : module.image.trailing}"
    cloud_init = "${module.last_run.value ?  module.cloud_init.leading  : module.cloud_init.trailing}"
    revision = "${module.last_run.value ? module.revision.leading : module.revision.trailing}"
  }
}

output "info" {
  value = {
    next = "${module.next.value}"
    last = "${module.last_run.value}"
    active = "${module.active.value}"
    pending = "${module.pending.value}"
    required = "${module.required.value}"

    flavor = "${module.flavor.info}"
    image = "${module.image.info}"
    cloud_init = "${module.cloud_init.info}"
    revision = "${module.revision.info}"
  }
}

output "active" {
  value = "${module.active.value}"
}
output "pending" {
  value = "${module.pending.value}"
}
output "last_run" {
  value = "${module.last_run.value}"
}
output "next" {
  value = "${module.next.value}"
}
