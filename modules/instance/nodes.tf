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


module "enforce_master_fips" {
  source = "../variable"
  value = "${module.use_bastion.value ? "${lookup(var.master,"assign_fips", "")}" : "single"}"
  default = "${var.assign_master_fips}"
}

locals {
  master_generation = "${max(var.generation,lookup(var.master,"generation",var.master_generation))}"
  worker_generation = "${max(var.generation,lookup(var.worker,"generation",var.worker_generation))}"
}

module "master_config" {
  source = "../access/node_config"
  node_config = "${var.master}"
  
  update_mode = "${module.recover_cluster.if_active ? "All" : "${lookup(var.master,"update_mode",var.master_update_mode)}"}"
  assign_fips = "${module.enforce_master_fips.value}"
  generation = "${local.master_generation}"

  flavor_name = "${module.master_vm.flavor_name}"
  image_name = "${module.master_vm.image_name}"

  defaults = {
    update_mode = "${var.node_update_mode}"
    count = "${var.master_count}"
    assign_fips = "${var.assign_master_fips}"
    volume_size = "${var.master_volume_size}"
    root_volume_size = "50"
  }
}

module "worker_config" {
  source = "../access/node_config"
  node_config = "${var.worker}"

  volume_size = "0"
  generation = "${local.worker_generation}"
  update_mode = "${lookup(var.worker,"update_mode",var.worker_update_mode)}"

  flavor_name = "${module.worker_vm.flavor_name}"
  image_name = "${module.worker_vm.image_name}"

  defaults = {
    update_mode = "${var.node_update_mode}"
    count = "${var.worker_count}"
    assign_fips = "${var.assign_worker_fips}"
    root_volume_size = "50"
  }
}


#####################################
# master nodes
#

module "master" {
  source = "../nodes"

  iaas_config        = "${var.iaas_config}"
  iaas_info          = "${module.iaas.iaas_info}"
  cloud_provider     = "${module.iaas.cloud_provider}"

  state              = "${var.master_state}"
  update_mode        = "${module.master_config.update_mode}"

  cluster_name       = "${var.cluster_name}"
  cluster_type       = "${var.cluster_type}"
  node_type          = "master"

  tags               = { "k8s.io/role/master" = "1" }

  generation         = "${module.master_config.generation}"
  vm_version         = "${module.recovery_version.value}"

  gen_dir            = "${module.cluster.gen_dir}"
  prefix             = "${module.cluster.prefix}"

  node_count         = "${module.master_config.count}"
  image_name         = "${module.master_config.image_name}"
  flavor_name        = "${module.master_config.flavor_name}"

  root_volume_size   = "${module.master_config.root_volume_size}"
  volume_size        = "${module.master_config.volume_size}"
  device             = "${module.iaas.device}"
  provide_storage    = true

  security_group     = "${module.iaas.security_group}"
  subnet_id          = "${module.iaas.subnet_id}"

  kubeconfig         = "${module.seed.kubeconfig}"

  dns_service_ip     = "${module.cluster.dns_service_ip}"
  root_certs         = "${module.root_certs.content}"

  kubernetes_version = "${module.versions.kubernetes_version}"
  kubernetes_hyperkube = "${module.versions.kubernetes_hyperkube}"
  kubernetes_hyperkube_patch = "${module.versions.kubernetes_hyperkube_patch}"
  cloud_conf         = "${module.iaas.cloud_conf}"
  cloud_init         = "${module.iaas.cloud_init}"
  key                = "${module.iaas.key}"

  assets_inst_dir    = "${module.cluster.assets_inst_dir}"
  bootkube_inst_dir  = "${module.cluster.bootkube_inst_dir}"
  bootkube_image     = "${module.versions.bootkube}:${module.versions.bootkube_version}"
  #provide_fips        = "${module.use_bastion.value ? "${var.assign_master_fips}" : "single"}"
  provide_fips       = "${module.master_config.assign_fips}"

  node_labels        = [ "node-role.kubernetes.io/master" ]
  node_taints        = [ "node-role.kubernetes.io/master=true:NoSchedule" ]

  provide_lbaas      = "${module.provide_lbaas.value}"
  lbaas_ports        = "${var.api_ports}"
  lbaas_description  = "API Server Loadbalancer" 
}


output "master" {
  value = "${module.master.fips}"
}
output "master_ips" {
  value = "${module.master.ips}"
}
output "master_count" {
  value = "${module.master_config.count}"
}

#####################################
# worker nodes
#

module "worker" {
  source = "../nodes"

  iaas_config        = "${var.iaas_config}"
  iaas_info          = "${module.iaas.iaas_info}"
  cloud_provider     = "${module.iaas.cloud_provider}"

  state              = "${var.worker_state}"
  update_mode        = "${module.worker_config.update_mode}"

  cluster_name       = "${var.cluster_name}"
  cluster_type       = "${var.cluster_type}"
  node_type          = "worker"

  tags               = { "k8s.io/role/node" = "1" }

  generation         = "${module.worker_config.generation}"

  gen_dir            = "${module.cluster.gen_dir}"
  prefix             = "${module.cluster.prefix}"

  node_count         = "${module.worker_config.count}"
  image_name         = "${module.worker_config.image_name}"
  flavor_name        = "${module.worker_config.flavor_name}"
  root_volume_size   = "${module.master_config.root_volume_size}"

  security_group     = "${module.iaas.security_group}"
  subnet_id          = "${module.iaas.subnet_id}"

  kubeconfig         = "${module.seed.kubeconfig}"

  dns_service_ip     = "${module.cluster.dns_service_ip}"
  root_certs         = "${module.root_certs.content}"

  kubernetes_version = "${module.versions.kubernetes_version}"
  kubernetes_hyperkube = "${module.versions.kubernetes_hyperkube}"
  kubernetes_hyperkube_patch = "${module.versions.kubernetes_hyperkube_patch}"
  cloud_conf         = "${module.iaas.cloud_conf}"
  cloud_init         = "${module.iaas.cloud_init}"
  key                = "${module.iaas.key}"

  provide_fips       = "${module.worker_config.assign_fips}"
  node_labels        = [ "node-role.kubernetes.io/node" ]

  provide_lbaas      = "${module.provide_lbaas_ingress.value}"
  lbaas_ports        = "${var.nginx_ports}"
  lbaas_description  = "NGINX Loadbalancer" 
}


output "worker" {
  value = "${module.worker.fips}"
}
output "worker_ips" {
  value = "${module.worker.ips}"
}
output "worker_count" {
  value = "${module.worker_config.count}"
}
