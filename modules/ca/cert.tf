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

variable "ca_cert_pem" {
  default =""
}
variable "ca_key_pem" {
  default =""
}
variable "file_base" {
  default =""
}

variable "common_name" {
}
variable "organization" {
}
variable "validity_period_hours" {
}
variable "allowed_uses" {
  default = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

module "local_ca" {
  source = "../flag"
  option = "${length(var.ca_cert_pem) == 0 || length(var.ca_key_pem) == 0}"
}

resource "tls_private_key" "ca" {
  count = "${module.local_ca.flag}"
  algorithm   = "RSA"
  rsa_bits = "2048"
}

module "ca_key_pem" {
  source = "../variable"
  value = "${element(compact(concat(tls_private_key.ca.*.private_key_pem,list(var.ca_key_pem))),0)}"
}

resource "local_file" "ca_key" {
  count = "${signum(length(var.file_base))}"
  content = "${module.ca_key_pem.value}"
  filename = "${var.file_base}.key"
}

resource "tls_self_signed_cert" "ca" {
  count = "${module.local_ca.flag}"
  key_algorithm   = "RSA"
  private_key_pem = "${module.ca_key_pem.value}"
  is_ca_certificate = true

  subject {
    common_name  = "${var.common_name}"
    organization = "${var.organization}"
  }

  validity_period_hours = "${var.validity_period_hours}"

  allowed_uses = "${var.allowed_uses}"
}

module "ca_cert_pem" {
  source = "../variable"
  value = "${element(compact(concat(tls_self_signed_cert.ca.*.cert_pem,list(var.ca_cert_pem))),0)}"
}
resource "local_file" "ca_crt" {
  count = "${signum(length(var.file_base))}"
  content = "${module.ca_cert_pem.value}"
  filename = "${var.file_base}.crt"
}

output "ca_key_pem" {
  value = "${module.ca_key_pem.value}"
}
output "ca_cert_pem" {
  value = "${module.ca_cert_pem.value}"
}
output "ca" {
  value = {
    key = "${module.ca_key_pem.value}"
    cert = "${module.ca_cert_pem.value}"
  }
}
