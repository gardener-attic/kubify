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

variable "private_key_pem" {
  type = "string"
}
variable "cert_pem" {
  type = "string"
}
variable "ca_cert" {
  type = "string"
}
variable "ca_key" {
  type = "string"
}
variable "file_base" {
  type = "string"
}
resource "local_file" "cert" {
  content = "${var.cert_pem}"
  filename = "${var.file_base}.crt"
}
resource "local_file" "api_key" {
  content = "${var.private_key_pem}"
  filename = "${var.file_base}.key"
}

output "private_key_pem" {
  value = "${var.private_key_pem}"
}
output "cert_pem" {
  value = "${var.cert_pem}"
}
output "ca_cert" {
  value = "${var.ca_cert}"
}
output "ca_key" {
  value = "${var.ca_key}"
}
output "private_key_pem_b64" {
  value = "${base64encode(var.private_key_pem)}"
}
output "cert_pem_b64" {
  value = "${base64encode(var.cert_pem)}"
}
output "ca_cert_b64" {
  value = "${base64encode(var.ca_cert)}"
}
output "ca_key_b64" {
  value = "${base64encode(var.ca_key)}"
}
