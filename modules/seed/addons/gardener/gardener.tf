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
# special handling for monitoring addon
################################################################

variable "config" {
  type = "map"
}
variable "dns" {
  type = "map"
}
variable "active" {
  type = "string"
}

variable "tls_dir" {
  type = "string"
}
variable "ca" {
  type = "string"
}
variable "ca_key" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}
variable "etcd_service_ip" {
  type = "string"
}
variable "versions" {
  type = "map"
}
variable "standard" {
  type = "map"
}

variable "namespace" {
  default = "garden"
}
variable "api_service_account" {
  default = "gardener-apiserver"
}

module "gardener" {
  source = "../../../flag"
  option = "${var.active}"
}

module "versions" {
  source = "../../../versions"
  versions = "${var.versions}"
}
module "route53_access" {
  source = "../../../access/aws"
  access_info = "${var.dns}"
} 

locals {
  domain = "${lookup(var.config, "domain", var.domain_name)}"
  access_key = "${lookup(var.config, "access_key", module.route53_access.access_key)}"
  secret_key = "${lookup(var.config, "secret_key", module.route53_access.secret_key)}"
  hosted_zone_id = "${lookup(var.config, "hosted_zone_id", lookup(var.dns,"hosted_zone_id",""))}"
  garden_domain = "${lookup(var.config, "domain", var.domain_name)}"
  dns_active = "${signum(length(local.hosted_zone_id))}"
}

data "template_file" "domain_secret" {
  count = "${local.dns_active}"
  template= "${file("${path.module}/templates/route53_domain_secret.yaml")}"
  vars {
    namespace = "${var.namespace}"
    domain = "${local.garden_domain}"
    route53_access_key_b64 = "${base64encode(local.access_key)}"
    route53_secret_key_b64 = "${base64encode(local.secret_key)}"
    hosted_zone_id = "${local.hosted_zone_id}"
  }
}

output "hosted_zone_id" {
  value = "${local.hosted_zone_id}"
}
output "dns_route53" {
  value = "${var.dns}"
}

module "domain_secret" {
  source = "../../../optrsc" 
  value = "${data.template_file.domain_secret.*.rendered}"
}

module "server" {
  source = "../../../tls"
  active = "${var.active}"

  file_base = "${var.tls_dir}"
  common_name = "gardener"
  organization = "SAP SE"
  ca = "${var.ca}"
  ca_key = "${var.ca_key}"

   dns_names = [
     "gardener-apiserver",
     "gardener-apiserver.${var.namespace}",
     "gardener-apiserver.${var.namespace}.svc",
     "gardener-apiserver.${var.namespace}.svc.cluster.local"
   ]
}

locals {
  dummy = {
    namespace = "${var.namespace}"
    api_service_account = "${var.api_service_account}"
    controller_service_account = "gardener-controller-manager"
    apiserver_replicas = 1
    apiserver_image = "${module.versions.garden_apiserver_image}"
    apiserver_version = "${module.versions.garden_apiserver_version}"
    controller_replicas = 1
    controller_image = "${module.versions.garden_controller_image}"
    controller_version = "${module.versions.garden_controller_version}"
    controller_port = 2718
    etcd_service_ip = "${var.etcd_service_ip}"

    domain_secret = ""
    apiserver_crt_b64 = ""
    apiserver_key_b64 = ""
  }

  default_values = {
    namespace = "${var.namespace}"
    api_service_account = "${var.api_service_account}"
    controller_service_account = "gardener-controller-manager"
    apiserver_replicas = 1
    apiserver_image = "${module.versions.garden_apiserver_image}"
    apiserver_version = "${module.versions.garden_apiserver_version}"
    controller_replicas = 1
    controller_image = "${module.versions.garden_controller_image}"
    controller_version = "${module.versions.garden_controller_version}"
    controller_port = 2718
    etcd_service_ip = "${var.etcd_service_ip}"
    apiserver_crt_b64 = "${module.server.cert_pem_b64}"
    apiserver_key_b64 = "${module.server.private_key_pem_b64}"

  }
  generated = {
    domain_secret = "${module.domain_secret.value}"
  }
}
#
# addon module api
#
output "dummy" {
  value = "${local.dummy}"
}
output "defaults" {
  value="${local.default_values}"
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
