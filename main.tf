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

variable "iaas_config" {
  type = "map"
}
variable "access_info" {
  type = "map"
}
variable "etcd_backup" {
  type = "map"
}

module "cluster"{
  source = "modules/cluster"

  cluster_name = "${var.cluster_name}"
  cluster_type = "${var.cluster_type}"
  service_cidr = "${var.service_cidr}"
  pod_cidr = "${var.pod_cidr}"
  platform = "${var.platform}"
  hosted_zone_domain = "${module.hosted_zone_domain.value}"
  base_domain  = "${module.base_domain.value}"
  domain_name  = "${module.domain_name.value}"
  additional_domains = "${var.additional_domains}"
  pull_secret = "${module.pull_secret.content}"
}

module "root_certs" {
  source = "modules/file"
  path = "${var.root_certs_file}"
}
module "pull_secret" {
  source = "modules/file"
  path = "${var.pull_secret_file}"
}

module "bastion_config" {
  source = "modules/access/node_config"
  node_config = "${var.bastion}"

  volume_size = "0"

  flavor_name = "${module.bastion_vm.flavor_name}"
  image_name = "${module.bastion_vm.image_name}"
  user_name = "${var.bastion_user}"

  defaults = {
    update_mode = "${var.node_update_mode}"
    count = "${var.worker_count}"
    assign_fips = "${var.assign_worker_fips}"
    user_name = "ubuntu"
  }
}

module "iaas" {
  source = "variants/current/modules/iaas"

  iaas_config    = "${var.iaas_config}"

  cluster_name = "${var.cluster_name}"
  cluster_type = "${var.cluster_type}"

  gen_dir = "${module.cluster.gen_dir}"
  prefix = "${module.cluster.prefix}"

  subnet_cidr = "${var.subnet_cidr}"
  dns_nameservers = "${var.dns_nameservers}"

  use_bastion = "${module.use_bastion.value}"
  bastion = "${module.bastion_config.node_config}"
}

data "archive_file" "helper_scripts" {
  type        = "zip"
  output_path = "${module.cluster.gen_dir}/helper.zip"
  source_dir = "${path.module}/resources/bin"
}

module "seed" {
  source = "modules/seed"

  cluster_name = "${var.cluster_name}"
  addons = "${var.addons}"

  gen_dir = "${module.cluster.gen_dir}"

  domain_name = "${module.cluster.domain_name}"
  ingress_base_domain = "${module.cluster.ingress_base_domain}"
  api_dns_name = "${module.cluster.api}"

  tls_dir    = "${module.cluster.tls_dir}"
  tls_kubelet = "${module.cluster.tls_kubelet}"
  tls_apiserver = "${module.cluster.tls_apiserver}"
  tls_etcd = "${module.cluster.tls_etcd}"
  tls_etcd_client = "${module.cluster.tls_etcd_client}"

  pull_secret_b64 = "${module.cluster.pull_secret_b64}"
  
  oidc_issuer_subdomain = "${var.oidc_issuer_subdomain}"
  oidc_client_id = "${var.oidc_client_id}"
  oidc_username_claim = "${var.oidc_username_claim}"
  oidc_groups_claim = "${var.oidc_groups_claim}"
  
  master_count = "${module.master_config.count}"
  service_cidr = "${var.service_cidr}"
  pod_cidr = "${var.pod_cidr}"
  cloud_provider = "${module.iaas.cloud_provider}"
  service_account_public_key_pem = "${module.cluster.service_account_public_key_pem}"
  service_account_private_key_pem = "${module.cluster.service_account_private_key_pem}"
  dns_service_ip = "${module.cluster.dns_service_ip}"
  bootstrap_etcd_service_ip = "${module.cluster.bootstrap_etcd_service_ip}"
  etcd_service_ip = "${module.cluster.etcd_service_ip}"
  host_ssl_certs_dir = "${var.host_ssl_certs_dir}"

  assets_inst_dir = "${module.cluster.assets_inst_dir}"
  etcd_backup_file = "${var.etcd_backup_file}"
  etcd_backup = "${var.etcd_backup}"

  use_lbaas = "${var.use_lbaas}"

  addon_dirs = "${module.iaas.addon-dirs}"
  addon_trigger = "${module.iaas.addon-trigger}"

  dashboard_user = "${var.dashboard_user}"
  dashboard_password = "${var.dashboard_password}"
  default_password = "${module.iaas.default_password}"
  dashboard_creds = "${var.dashboard_creds}"

  versions = "${module.versions.versions}"
  vm_version = "${module.recovery_version.value}"

  access_info = "${var.access_info}"
  cluster_info = "${module.cluster.cluster-info}"
}

output "gen_dir" {
  value = "${module.cluster.gen_dir}"
}

output "etcd_service_ip" {
  value = "${module.cluster.etcd_service_ip}"
}

output "access_info" {
  value = "${var.access_info}"
}
