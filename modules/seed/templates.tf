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

module "versions" {
  source = "../versions"
  versions = "${var.versions}"
}

data "template_file" "kubelet_conf" {
  template = "${file("${path.module}/templates/kubelet.conf")}"

  vars {
    cacert_b64 = "${module.kubelet.ca_cert_b64}"
    api_url = "${var.use_lbaas == 0? "https://127.0.0.1:443" : "https://${var.api_dns_name}:443"}"
    kubelet_cert_b64 = "${module.kubelet.cert_pem_b64}"
    kubelet_key_b64 = "${module.kubelet.private_key_pem_b64}"
    cluster_name = "${var.cluster_name}"
  }
}

resource "local_file" "kubelet_conf" {
  content = "${data.template_file.kubelet_conf.rendered}"
  filename = "${var.gen_dir}/assets/auth/kubeconfig"
}
resource "local_file" "cluster_info" {
  content = "${var.cluster_info}"
  filename = "${var.gen_dir}/assets/cluster-info"
}

module "use_oidc" {
  source = "../flag"
  option = "${length("${var.oidc_issuer_subdomain}${var.oidc_issuer_domain}") > 0 ? 1 : module.dex.if_active}"
}
module "oidc_issuer_domain" {
  source = "../variable"
  value = "${var.oidc_issuer_domain}"
  default = "${var.oidc_issuer_subdomain}.${var.domain_name}"
}

module "oidc_ca" {
  source = "../file"
  path = "${var.oidc_ca_file}"
}

locals {
  oidc_cfg_secret_name = "oidc-ca.crt"

  oidc_ca_secret = "${module.use_oidc.if_active && length(var.oidc_ca_file) > 0 ? "  ${local.oidc_cfg_secret_name}=${module.oidc_ca.b64}" : ""}"

  oidc_cfg_ca_file = "${module.use_oidc.if_active ? (length(var.oidc_ca_file) > 0 ? "/etc/kubernetes/secrets/${local.oidc_cfg_secret_name}" : (var.oidc_use_cluster_ca ? "/etc/kubernetes/secrets/ca.crt": "")) : ""}"
  oidc_ca_file = "${module.dex.if_active ? module.dex.oidc["oidc-ca-file"] : local.oidc_cfg_ca_file}" 
  oidc_optional = "${module.use_oidc.if_active && length(local.oidc_ca_file) > 0 ? "--oidc-ca-file=${local.oidc_ca_file}" : ""}"
}

data "template_file" "oidc" {
  template = "${file("${path.module}/templates/misc/oidc.dropin")}"

  vars {
    oidc-optional = "${local.oidc_optional}"
    oidc-issuer-url = "${module.dex.if_active ? module.dex.oidc["oidc-issuer-url"] : "https://${module.oidc_issuer_domain.value}"}"
    oidc-client-id  = "${module.dex.if_active ? module.dex.oidc["oidc-client-id"] : var.oidc_client_id}"
    oidc-username-claim  = "${module.dex.if_active ? module.dex.oidc["oidc-username-claim"] : var.oidc_username_claim}"
    oidc-groups-claim  = "${module.dex.if_active ? module.dex.oidc["oidc-groups-claim"] : var.oidc_groups_claim}"
  }
}

locals {
  oidc_dropin = "${module.use_oidc.if_active ? indent(8,join("\n",formatlist("- %s",compact(split("\n",data.template_file.oidc.rendered))))) : ""}"
}

locals {
  etcd_servers_by_service = "https://${var.etcd_service_ip}:2379}"
  etcd_servers_by_dns = "${join(",",formatlist("https://%s:2379",var.etcd_domains))}"
  etcd_servers = "${module.selfhosted_etcd.if_active ? local.etcd_servers_by_service : local.etcd_servers_by_dns}"
  etcd_members = "${formatlist("%s=https://%s:2380", var.etcd_names, var.etcd_domains)}"
  etcd_predecessors = "${concat(list(""),formatlist("https://%s:2379",var.etcd_domains))}"
}

locals {
  bootkube_vars {
    cluster_name = "${var.cluster_name}"
    oidc_dropin = "${local.oidc_dropin}"
    kubernetes_version = "${module.versions.kubernetes_version}"
    kubernetes_hyperkube = "${module.versions.kubernetes_hyperkube}"
    kubernetes_hyperkube_patch = "${module.versions.kubernetes_hyperkube_patch}"
    control_plane_replicas = "${max(2,var.master_count)}"
    master_count = "${var.master_count}"
    service_cidr = "${var.service_cidr}"
    pod_cidr = "${var.pod_cidr}"
    cloud_provider = "${var.cloud_provider}"
    api_aggregator_crt_b64 = "${module.aggregator.cert_pem_b64}"
    api_aggregator_key_b64 = "${module.aggregator.private_key_pem_b64}"
    apiserver_crt_b64 = "${module.apiserver.cert_pem_b64}"
    apiserver_key_b64 = "${module.apiserver.private_key_pem_b64}"
    apiserver_ca_crt_b64 = "${module.apiserver.ca_cert_b64}"
    etcd_client_ca_crt_b64 = "${module.etcd-client.ca_cert_b64}"
    etcd_client_crt_b64 = "${module.etcd-client.cert_pem_b64}"
    etcd_client_key_b64 = "${module.etcd-client.private_key_pem_b64}"
    etcd_servers = "${local.etcd_servers}"
    etcd0_domain = "${var.etcd_domains[0]}"
    etcd_base_domain = "${var.etcd_base_domain}"
    service_account_pub_b64 = "${base64encode(var.service_account_public_key_pem)}"
    service_account_key_b64 = "${base64encode(var.service_account_private_key_pem)}"
    controller_manager_ca_crt_b64 = "${module.apiserver.ca_cert_b64}"
    dns_version = "${module.versions.dns_version}"
    dns_service_ip = "${var.dns_service_ip}"
    flannel_version = "${module.versions.flannel_version}"
    cni_version = "${module.versions.cni_version}"
    etcd_version = "${module.versions.etcd_version}"
    bootstrap_etcd_service_ip = "${var.bootstrap_etcd_service_ip}"
    etcd_service_ip = "${var.etcd_service_ip}"
    etcd_peer_ca_crt_b64 = "${module.etcd.peer_ca_cert_b64}"
    etcd_peer_crt_b64 = "${module.etcd.peer_cert_pem_b64}"
    etcd_peer_key_b64 = "${module.etcd.peer_private_key_pem_b64}"
    etcd_server_ca_crt_b64 = "${module.etcd.server_ca_cert_b64}"
    etcd_server_crt_b64 = "${module.etcd.server_cert_pem_b64}"
    etcd_server_key_b64 = "${module.etcd.server_private_key_pem_b64}"
    etcd_operator_version = "${module.versions.etcd_operator_version}"

    etcd_volumes = "${module.etcd_volumes.value}"
    etcd_args = "${module.etcd_initial.value}"
    etcd_mounts = "${module.etcd_mount.value}"
    etcd_initcontainers = "${module.etcd_initcontainers.value}"

    event_ttl = "${var.event_ttl}"
    ssl_certs_dir = "${var.host_ssl_certs_dir}"
    pull_secret_b64 = "${var.pull_secret_b64}"

    oidc_ca_secret = "${local.oidc_ca_secret}"
  }
}

module "selfhosted_etcd" {
  source = "../flag"
  option = "${var.selfhosted_etcd}"
}

resource "template_dir" "bootkube-common" {
  source_dir = "${path.module}/templates/bootkube/common"
  destination_dir = "${var.gen_dir}/bootkube/common"

  vars = "${local.bootkube_vars}"
}
resource "template_dir" "bootkube-self" {
  count = "${module.selfhosted_etcd.if_active}"
  source_dir = "${path.module}/templates/bootkube/self"
  destination_dir = "${var.gen_dir}/bootkube/self"

  vars = "${local.bootkube_vars}"
}
resource "template_dir" "bootkube-single" {
  count = "${module.selfhosted_etcd.if_not_active}"
  source_dir = "${path.module}/templates/bootkube/single"
  destination_dir = "${var.gen_dir}/bootkube/single"

  vars = "${local.bootkube_vars}"
}

module "dashboard_user" {
  source = "../variable"
  value = "${var.dashboard_user}"
  default = "${var.cluster_name}-admin"
}
module "dashboard_password" {
  source = "../variable"
  value = "${var.dashboard_password}"
  default = "${var.default_password}"
}
module "dashboard_creds" {
  source = "../variable"
  value = "${var.dashboard_creds}"
  default = "${module.dashboard_user.value}:${bcrypt(module.dashboard_password.value)}"
}

module "distinct_manifests" {
  source = "../variable"
  value = "${var.gen_dir}/addons/distinct/manifests"
}

module "tiller" {
  source = "../flag"
  option = "${var.deploy_tiller || contains(keys(var.addons),"gardener")}"
}

data "template_file" "tiller" {
  count    = "${module.tiller.if_active}"
  template = "${file("${path.module}/templates/misc/kube-helm.yaml")}"

  vars {
    tiller_version = "${module.versions.tiller_version}"
    tiller_image = "${module.versions.tiller_image}"
    helm_version = "${module.versions.helm_version}"
    helm_image = "${module.versions.helm_image}"
  }
}
resource "local_file" "tiller" {
  count    = "${module.tiller.if_active}"
  content  = "${data.template_file.tiller.rendered}"
  filename = "${module.distinct_manifests.value}/kube-helm.yaml"
}

#
# copy all resources into a single location for archive file generation
#
resource "null_resource" "manifests" {
  depends_on = ["template_dir.bootkube-common" ]
  triggers {
    bootkube = "${template_dir.bootkube-common.id}"
    single   = "${join("",template_dir.bootkube-single.*.id)}"
    self     = "${join("",template_dir.bootkube-self.*.id)}"
    tiller   = "${join("",local_file.tiller.*.id)}"
    backup   = "${module.etcd_backup_id.value}"
    iaas     = "${var.addon_trigger}"
    script   = "${sha256(file("${path.module}/scripts/prepare_assets.sh"))}"
    #command  = "${path.module}/scripts/prepare_assets.sh \"${var.gen_dir}/assets\" \"${var.gen_dir}/bootkube\" ${join(" ",formatlist("${var.gen_dir}/addons/%s",concat(local.selected,list("distinct"))))} \"${module.iaas-addons.value}\""
    command  = "${path.module}/scripts/prepare_assets.sh \"${var.gen_dir}/assets\" \"${var.gen_dir}/bootkube\"/* \"${var.gen_dir}/addons/distinct\" \"${module.iaas-addons.value}\""
  }

  provisioner "local-exec" {
    command  = "${self.triggers.command}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "rm -rf \"${var.gen_dir}/assets/manifests\""
  }
}

resource "null_resource" "archive_deps" {
  depends_on = [ "template_dir.bootkube-common", "local_file.cluster_info", "local_file.kubelet_conf", "module.kubelet", "module.apiserver", "module.etcd", "module.etcd-client", "null_resource.etcd_backup" ]
  triggers {
    secrets = "${module.etcd.trigger},${module.etcd-client.trigger}"
    cluster_info = "${local_file.cluster_info.id}"
    addon_deploy   = "${join(",",null_resource.deploy.*.id)}"
    addons   = "${join(",",template_dir.addons.*.id)}"
    manifests = "${null_resource.manifests.id}"
    backup   = "${module.etcd_backup_id.value}"
    recover = "${var.vm_version}"
  }
  provisioner "local-exec" {
    command  = "echo repack assets"
  }
}

data "archive_file" "bootkube" {
  type        = "zip"
  output_path = "${var.gen_dir}/bootkube.zip"
  source_dir = "${element(list("${var.gen_dir}/assets", null_resource.archive_deps.id),0)}"
}

data "archive_file" "etcdtls" {
  count = "${module.selfhosted_etcd.if_not_active}"
  type        = "zip"
  output_path = "${var.gen_dir}/etcdtls.zip"
  source_dir = "${element(list("${var.gen_dir}/etcdtls", null_resource.archive_deps.id),0)}"
}

data "template_file" "static_etcd" {
  count = "${var.master_count * module.selfhosted_etcd.if_not_active}"
  template = "${file("${path.module}/templates/etcd_bootstrap/static_etcd.yaml")}"
  vars {
    service_name = "${var.etcd_service_name}"
    service_ip = "${var.etcd_service_ip}"
    name = "${var.etcd_names[count.index]}"
    version = "${module.versions.etcd_version}"
    endpoints = "${local.etcd_servers_by_dns}"
    predecessor = "${local.etcd_predecessors[count.index]}"
    domain = "${var.etcd_domains[count.index]}"
    initial_cluster = "${join(",",slice(local.etcd_members,0,count.index+1))}"

    recover_volumes = "${count.index == 0 ? module.etcd_volumes.value : ""}"
    recover_args = "${count.index == 0 ? module.etcd_initial.value : ""}"
    recover_mounts = "${count.index == 0 ? module.etcd_mount.value : ""}"
    recover_initcontainers = "${count.index == 0 ? module.etcd_initcontainers.value : ""}"
  }
}

data "template_file" "kubelet_env" {
  template = "${file("${path.module}/templates/kubelet.env")}"

  vars {
    kubelet_version = "${module.versions.kubernetes_version}${module.versions.kubernetes_hyperkube_patch}"
    kubelet_image_tag = "${module.versions.kubernetes_version}${module.versions.kubernetes_hyperkube_patch}"
    kubelet_image = "${module.versions.kubernetes_hyperkube}"
  }
}

output "etcdtls_sha" {
  value = "${join("",data.archive_file.etcdtls.*.output_sha)}"
}
output "etcdtls_path" {
  value = "${join("",data.archive_file.etcdtls.*.output_path)}"
}
output "etcd_manifests" {
  value = "${data.template_file.static_etcd.*.rendered}"
}

resource "local_file" "kubelet_env" {
  content = "${data.template_file.kubelet_env.rendered}"
  filename = "${var.gen_dir}/kubelet.env"
}

output "bootkube_sha" {
  value = "${data.archive_file.bootkube.output_sha}"
}
output "bootkube_path" {
  value = "${data.archive_file.bootkube.output_path}"
}
output "kubelet_env" {
  value = "${data.template_file.kubelet_env.rendered}"
}
output "kubeconfig" {
  value = "${data.template_file.kubelet_conf.rendered}"
}
