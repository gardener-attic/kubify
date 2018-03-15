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

################################################################
# special handling for external-dns addon
################################################################

variable "config" {
  type = "map"
}
variable "active" {
  type = "string"
}

variable "versions" {
  type = "map"
}
variable "iaas_config" {
  type = "map"
}
variable "vm_info" {
  type = "map"
}


variable "namespace" {
  default = "kubify-machines"
}

module "versions" {
  source = "../../../versions"
  versions = "${var.versions}"
}

module "addon" {
  source = "../../../flag"
  option = "${var.active}"
}


module "machine" {
  source = "../../../../variants/current/modules/machine"
  namespace = "${var.namespace}"
  iaas_config = "${var.iaas_config}"
  vm_info = "${var.vm_info}"
  count = "${lookup(var.config,"worker_count","0")}"
}

locals {

  defaults = {
    namespace = "${var.namespace}"
    version = "${module.versions.machine_controller_version}"
    image = "${module.versions.machine_controller_image}"
    worker_count = 1
  }

  dummy = {
    namespace = "${var.namespace}"
    image = ""
    workerdef = ""
    worker_count = ""
  }

  config = "${merge(local.defaults,var.config)}"
}

locals {
  generated = {
    workerdef = "${module.machine.manifests}"
  }
}

#
# addon module api
#
output "dummy" {
  value = "${local.dummy}"
}
output "defaults" {
  value="${local.defaults}"
}
output "generated" {
  value="${local.generated}"
}

output "manifests" {
  value="${path.module}/templates/manifests"
}

output "deploy" {
  value=""
}
