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


variable "namespace" {
  default = "nginx-ingress"
}

module "versions" {
  source = "../../../versions"
  versions = "${var.versions}"
}

module "addon" {
  source = "../../../flag"
  option = "${var.active}"
}


locals {

  defaults = {
    namespace = "${var.namespace}"
    version = "${module.versions.external_dns_version}"
    image = "${module.versions.external_dns_image}"
  }

  dummy = {
    namespace = "${var.namespace}"
    image = ""
  }

  config = "${merge(local.defaults,var.config)}"
}

locals {
  generated = {
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
