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

variable "file_base" {
  type = "string"
}
variable "common_name" {
  type = "string"
}
variable "organization" {
  type = "string"
}
variable "allowed_uses" {
  type = "list"
  default = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth"
  ]
}
variable "dns_names" {
  type = "list"
  default = [
  ]
}
variable "ip_addresses" {
  type = "list"
  default = [
    "127.0.0.1"
  ]
}
variable "ca" {
  type = "string"
}
variable "ca_key" {
  type = "string"
}

resource "tls_private_key" "key" {
  algorithm   = "RSA"
  rsa_bits = "2048"
}
resource "tls_cert_request" "request" {
  key_algorithm   = "RSA"
  private_key_pem = "${tls_private_key.key.private_key_pem}"

  subject {
    common_name  = "${var.common_name}"
    organization = "${var.organization}"
  }

  ip_addresses = "${var.ip_addresses}"

  dns_names = "${var.dns_names}"
}
resource "tls_locally_signed_cert" "cert" {
  cert_request_pem   = "${tls_cert_request.request.cert_request_pem}"
  ca_key_algorithm   = "RSA"
  ca_private_key_pem = "${var.ca_key}"
  ca_cert_pem        = "${var.ca}"

  validity_period_hours = "${3650*24}"

  allowed_uses = "${var.allowed_uses}"
}
resource "local_file" "ca" {
  content = "${var.ca}"
  filename = "${var.file_base}-ca.crt"
}
#resource "local_file" "ca-key" {
#  content = "${var.ca_key}"
#  filename = "${var.file_base}-ca.key"
#}
resource "local_file" "cert" {
  content = "${tls_locally_signed_cert.cert.cert_pem}"
  filename = "${var.file_base}.crt"
}
resource "local_file" "key" {
  content = "${tls_private_key.key.private_key_pem}"
  filename = "${var.file_base}.key"
}
resource "local_file" "pub" {
  content = "${tls_private_key.key.public_key_pem}"
  filename = "${var.file_base}.pub"
}

output "tls" {
  value = {
    private_key_pem = "${tls_private_key.key.private_key_pem}"
    public_key_pem = "${tls_private_key.key.public_key_pem}"
    cert_pem = "${tls_locally_signed_cert.cert.cert_pem}"
    ca_cert = "${var.ca}"
    ca_key =  "${var.ca_key}"
  }
}

output "private_key_pem" {
  value = "${tls_private_key.key.private_key_pem}"
}
output "public_key_pem" {
  value = "${tls_private_key.key.public_key_pem}"
}
output "cert_pem" {
  value = "${tls_locally_signed_cert.cert.cert_pem}"
}
output "ca_cert" {
  value = "${var.ca}"
}
output "ca_key" {
  value = "${var.ca_key}"
}
output "private_key_pem_b64" {
  value = "${base64encode(tls_private_key.key.private_key_pem)}"
}
output "public_key_pem_b64" {
  value = "${base64encode(tls_private_key.key.public_key_pem)}"
}
output "cert_pem_b64" {
  value = "${base64encode(tls_locally_signed_cert.cert.cert_pem)}"
}
output "ca_cert_b64" {
  value = "${base64encode(var.ca)}"
}
output "ca_key_b64" {
  value = "${base64encode(var.ca_key)}"
}
