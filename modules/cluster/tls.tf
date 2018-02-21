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

#
# ca
#

module "ca" {
  source = "../ca"
  
  ca_cert_pem = "${var.ca_cert_pem}"
  ca_key_pem = "${var.ca_key_pem}"

  common_name  = "kubernetes"
  organization = "SAP SE"
  validity_period_hours = "${3650*24}" // 10 years :-)
  file_base = "${module.tls_dir.value}/ca"
}

output "ca_key_pem" {
  value = "${module.ca.ca_key_pem}"
}
output "ca_cert_pem" {
  value = "${module.ca.ca_cert_pem}"
}

#
# kubelet certificate
#
module "kubelet" {
  source = "../tls"

  file_base = "${module.tls_dir.value}/kubelet"
  common_name = "kubelet"
  organization = "system:masters"
  ca = "${module.ca.ca_cert_pem}"
  ca_key = "${module.ca.ca_key_pem}"
  ip_addresses = []
}

#
# api certificate
#
variable "std_api_domains" {
  default = [
      "kubernetes",
      "kubernetes.default",
      "kubernetes.default.svc",
      "kubernetes.default.svc.cluster.local"
  ]
}

#
# api server certificate
#
module "apiserver" {
  source = "../tls"

  file_base = "${module.tls_dir.value}/apiserver"
  common_name = "kube-apiserver"
  organization = "kube-master"
  ca = "${module.ca.ca_cert_pem}"
  ca_key = "${module.ca.ca_key_pem}"

  ip_addresses = "${concat(list("127.0.0.1", "${module.api_service_ip.value}"))}"

  dns_names = "${concat(var.std_api_domains,module.api_domains.value, list("*.${var.domain_name}"))}"
}

#
# aggregator certificate
#
module "aggregator" {
  source = "../tls"

  file_base = "${module.tls_dir.value}/aggregator"
  common_name = "system:kube-aggregator"
  organization = "kube-master"
  ca = "${module.ca.ca_cert_pem}"
  ca_key = "${module.ca.ca_key_pem}"
}

################################################################################

#
# service account certificate
#
resource "tls_private_key" "service_account" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}
resource "local_file" "service_account_pub" {
  content = "${tls_private_key.service_account.public_key_pem}"
  filename = "${module.tls_dir.value}/service-account.pub"
}
resource "local_file" "service_account_key" {
  content = "${tls_private_key.service_account.private_key_pem}"
  filename = "${module.tls_dir.value}/service-account.key"
}

output "service_account_private_key_pem" {
  value = "${tls_private_key.service_account.private_key_pem}"
}
output "service_account_public_key_pem" {
  value = "${tls_private_key.service_account.public_key_pem}"
}

#
# etcd client certificate
#
module "etcd_client" {
  source = "../tls"

  file_base = "${module.tls_dir.value}/etcd-client"
  common_name = "etcd-client"
  organization = "etcd"
  ca = "${module.ca.ca_cert_pem}"
  ca_key = "${module.ca.ca_key_pem}"
}

#
# etcd certificate
#
module "etcd" {
  source = "../etcd_tls"

  tls_dir = "${module.tls_dir.value}/etcd"
  service = "${var.etcd_name}"
  file_prefix = "${var.etcd_file_prefix}"
  namespace = "${var.namespace}"
  service_ip = "${module.etcd_service_ip.value}"
  ca = "${module.ca.ca_cert_pem}"
  ca_key = "${module.ca.ca_key_pem}"
  dns_names = [ "localhost" ]
  ip_addresses = [ "${module.bootstrap_etcd_service_ip.value}", "127.0.0.1" ]
}

output "tls_kubelet" {
  value = "${module.kubelet.tls}"
}
output "tls_apiserver" {
  value = "${module.apiserver.tls}"
}
output "tls_aggregator" {
  value = "${module.aggregator.tls}"
}
output "tls_etcd" {
  value = "${module.etcd.tls}"
}
output "tls_etcd_client" {
  value = "${module.etcd_client.tls}"
}
