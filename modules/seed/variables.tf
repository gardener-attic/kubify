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


variable "versions" {
  type="map"
}
variable "cluster_name" {
  type="string"
}
variable "addons" {
  type="map"
}
variable "gen_dir" {
  type="string"
}
variable "domain_name" {
  type="string"
}
variable "ingress_base_domain" {
  type="string"
}
variable "use_lbaas" {
  type="string"
}
variable "master_count" {
  type="string"
}

variable "tls_dir" {
  type="string"
}
variable "cloud_provider" {
  type="string"
}

variable "service_account_private_key_pem" {
  type = "string"
}
variable "service_account_public_key_pem" {
  type = "string"
}


variable "tls_kubelet" {
  type = "map"
}
variable "tls_apiserver" {
  type = "map"
}

variable "tls_etcd" {
  type = "map"
}
variable "tls_etcd_client" {
  type = "map"
}


variable "api_dns_name" {
  type = "string"
}

variable "service_cidr" {
  type = "string"
}
variable "pod_cidr" {
  type = "string"
}

variable "bootstrap_etcd_service_ip" {
  type = "string"
}
variable "etcd_service_ip" {
  type = "string"
}
variable "dns_service_ip" {
  type = "string"
}

variable "dashboard_user" {
  type = "string"
  default = ""
}
variable "dashboard_password" {
  type = "string"
  default = ""
}
variable "default_password" {
  type = "string"
  default = ""
}
variable "dashboard_creds" {
  type = "string"
  default = ""
}

variable "oidc_issuer_domain" {
  default = ""
}
variable "oidc_issuer_subdomain" {
  default = ""
}
variable "oidc_client_id" {
  default = "kube-kubectl"
}
variable "oidc_username_claim" {
  default = "email"
}
variable "oidc_groups_claim" {
  default = "groups"
}

variable "addon_dirs" {
  type = "list"
  default = []
}
variable "addon_trigger" {
  type = "string"
  default = ""
}

variable "host_ssl_certs_dir" {
  type = "string"
}
variable "pull_secret_b64" {
  type = "string"
}
variable "cluster_info" {
  type = "string"
}

variable "etcd_backup_file" {
  type="string"
  default = ""
}
variable "vm_version" {
  default = "0"
}
variable "assets_inst_dir" {
  type="string"
}
variable "etcd_backup" {
  type = "map"
}
variable "access_info" {
  type = "map"
}
