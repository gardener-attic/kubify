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


variable "service" {
  type = "string"
}
variable "namespace" {
  type = "string"
}
variable "file_prefix" {
  type = "string"
  default = ""
}

variable "ca" {
  type = "string"
}
variable "ca_key" {
  type = "string"
}
variable "tls_dir" {
  type = "string"
}
variable "service_ip" {
  type = "string"
}
variable "dns_names" {
  type = "list"
  default = [ ]
}
variable "ip_addresses" {
  type = "list"
  default = [ ]
}

module "dns_names" {
  source = "../listvar"
  value = [
    "*.${var.service}.${var.namespace}.svc.cluster.local",
    "*.${var.service}.${var.namespace}.svc",
    "*.${var.service}.${var.namespace}",
    "*.${var.service}"
  ]
}

#
# etcd certificate
#
module "etcd_peer" {
  source = "../tls"

  file_base = "${var.tls_dir}/${var.file_prefix}peer"
  common_name = "${var.service}-peer"
  organization = "etcd"
  ca = "${var.ca}"
  ca_key = "${var.ca_key}"

  dns_names = "${compact(concat(var.dns_names,module.dns_names.value))}"
  ip_addresses = "${compact(concat(list(var.service_ip),var.ip_addresses))}"
}

module "etcd_server" {
  source = "../tls"

  file_base = "${var.tls_dir}/${var.file_prefix}server"
  common_name = "${var.service}-server"
  organization = "etcd"
  ca = "${var.ca}"
  ca_key = "${var.ca_key}"

  dns_names = "${compact(concat(var.dns_names,module.dns_names.value))}"
  ip_addresses = "${compact(concat(list(var.service_ip),var.ip_addresses))}"
}

output "ca_cert" {
  value = "${var.ca}"
}
output "private_key_pem" {
  value = "${module.etcd_server.private_key_pem}"
}
output "cert_pem" {
  value = "${module.etcd_server.cert_pem}"
}
output "peer_private_key_pem" {
  value = "${module.etcd_peer.private_key_pem}"
}
output "peer_cert_pem" {
  value = "${module.etcd_peer.cert_pem}"
}

output "ca_cert_b64" {
  value = "${module.etcd_server.ca_cert_b64}"
}
output "private_key_pem_b64" {
  value = "${module.etcd_server.private_key_pem_b64}"
}
output "cert_pem_b64" {
  value = "${module.etcd_server.cert_pem_b64}"
}
output "peer_private_key_pem_b64" {
  value = "${module.etcd_peer.private_key_pem_b64}"
}
output "peer_cert_pem_b64" {
  value = "${module.etcd_peer.cert_pem_b64}"
}

output "tls_server" {
  value = "${module.etcd_server.tls}"
}
output "tls_peer" {
  value = "${module.etcd_peer.tls}"
}

output "tls" {
  value = {
    server = "${module.etcd_server.tls}"
    peer =   "${module.etcd_peer.tls}"
  }
}

