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

variable "platform" {
  default = "openstack"
}
variable "ca_cert_pem" {
  default = ""
}
variable "ca_key_pem" {
  default = ""
}

variable "cluster_name" {
  type = "string"
}
variable "cluster_type" {
  type = "string"
}
variable "etcd_name" {
  default = "kube-etcd"
}
variable "etcd_file_prefix" {
  default = ""
}
variable "etcd_service_ip" {
  default = ""
}
variable "namespace" {
  type = "string"
  default = "kube-system"
}

variable "hosted_zone_domain" {
  type = "string"
  default=""
}
variable "base_domain" {
  type = "string"
  default = ""
}
variable "domain_name" {
  type = "string"
  default = ""
}
variable "additional_domains" {
  type = "list"
  default =  []
}
variable "service_cidr" {
  type = "string"
}
variable "pod_cidr" {
  type = "string"
}

variable "bootkube_inst_dir" {
  default = "/opt/bootkube"
}

variable "pull_secret" {
  default = ""
}

locals {
  domain_keys={
    "openstack" = "os"
    "azure" = "az"
  }
}
module "domain_key" {
  source = "../variable"
  value = "${lookup(local.domain_keys, var.platform,var.platform)}"
}
module "base_domain" {
  source = "../variable"
  value = "${var.base_domain}"
  default = "${var.cluster_type}.${module.domain_key.value}.${var.hosted_zone_domain}"
}
module "domain_name" {
  source = "../variable"
  value = "${var.domain_name}"
  default = "${var.cluster_name}.${module.base_domain.value}"
}
module "domain_names" {
  source = "../listvar"
  value = "${concat(list(module.domain_name.value),var.additional_domains)}"
}
module "api_domains" {
  source = "../listvar"
  value = "${formatlist("api.%s",module.domain_names.value)}"
}

module "ingress" {
  source = "../variable"
  value = "ingress.${module.domain_name.value}"
}

module "assets_gen_dir" {
  source = "../variable"
  value = "${module.gen_dir.value}/assets"
}
module "assets_inst_dir" {
  source = "../variable"
  value = "${var.bootkube_inst_dir}/assets"
}
module "gen_dir" {
  source = "../variable"
  value = "${path.cwd}/gen"
}
module "tls_dir" {
  source = "../variable"
  value = "${module.assets_gen_dir.value}/tls"
}
locals {
  tls_dir = "${module.tls_dir.value}"
  api_domain = "api.${module.domain_name.value}"
}

data "template_file" "cluster-info" {
  template = "${file("${path.module}/templates/cluster-info")}"
  vars {
    bootstrap_etcd_service_ip = "${module.bootstrap_etcd_service_ip.value}"
    etcd_service_ip = "${module.etcd_service_ip.value}"
    api_service_ip = "${module.api_service_ip.value}"
    dns_service_ip = "${module.dns_service_ip.value}"
    service_cidr = "${var.service_cidr}"
    pod_cidr = "${var.pod_cidr}"
    api_dns_name="${local.api_domain}"
  }
}

output "cluster-info" {
  value = "${data.template_file.cluster-info.rendered}"
}

output "domain_name" {
  value = "${module.domain_name.value}"
}
output "domain_names" {
  value = "${module.domain_names.value}"
}

output "api" {
  value = "${local.api_domain}"
}
output "api_domains" {
  value = "${module.api_domains.value}"
}
output "identity" {
  value = "identity.ingress.${module.domain_name.value}"
}
output "identity_domains" {
  value = "${formatlist("identity.ingress.%s",module.domain_names.value)}"
}
output "ingress" {
  value = "*.${module.ingress.value}"
}
output "ingress_domains" {
  value = "${formatlist("*.ingress.%s",module.domain_names.value)}"
}
output "ingress_base_domain" {
  value = "${module.ingress.value}"
}

module "api_service_ip" {
  source = "../variable"
  value = "${cidrhost(var.service_cidr,1)}"
}
module "dns_service_ip" {
  source = "../variable"
  value = "${cidrhost(var.service_cidr,10)}"
}
module "etcd_service_ip" {
  source = "../variable"
  value = "${var.etcd_service_ip}"
  default = "${cidrhost(var.service_cidr,15)}"
}
module "bootstrap_etcd_service_ip" {
  source = "../variable"
  value = "${var.cluster_type != "shoot" ? cidrhost(var.service_cidr,20) : ""}"
}

output "bastion" {
  value = "bastion.${module.domain_name.value}"
}
output "api_url" {
  value = "https://api.${module.domain_name.value}"
}
output "api_service_ip" {
  value = "${module.api_service_ip.value}"
}
output "dns_service_ip" {
  value = "${module.dns_service_ip.value}"
}
output "prefix" {
  value = "${var.cluster_name}-${var.cluster_type}"
}
output "bootstrap_etcd_service_ip" {
  value = "${module.bootstrap_etcd_service_ip.value}"
}
output "etcd_service_ip" {
  value = "${module.etcd_service_ip.value}"
}

output "assets_gen_dir" {
  value = "${module.assets_gen_dir.value}"
}
output "tls_dir" {
  value = "${local.tls_dir}"
}
output "gen_dir" {
  value = "${module.gen_dir.value}"
}

output "namespace" {
  value = "${var.namespace}"
}

output "bootkube_inst_dir" {
  value = "${var.bootkube_inst_dir}"
}
output "assets_inst_dir" {
  value = "${module.assets_inst_dir.value}"
}

output "pull_secret_b64" {
  value = "${base64encode(var.pull_secret)}"
}

