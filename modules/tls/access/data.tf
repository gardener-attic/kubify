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


variable "tls" {
  type = "map"
}

variable "file_base" {
  default = ""
}

module "save" {
  source = "../../flag"
  option = "${length(var.file_base) > 0}"
}

resource "local_file" "ca" {
  count = "${module.save.if_active}"
  content = "${lookup(var.tls,"ca_cert")}"
  filename = "${var.file_base}-ca.crt"
}
#resource "local_file" "ca-key" {
#  count = "${module.save.if_active}"
#  content = "${lookup(var.tls,"ca_key")}"
#  filename = "${var.file_base}-ca.key"
#}
resource "local_file" "cert" {
  count = "${module.save.if_active}"
  content = "${lookup(var.tls,"cert_pem")}"
  filename = "${var.file_base}.crt"
}
resource "local_file" "key" {
  count = "${module.save.if_active}"
  content = "${lookup(var.tls,"private_key_pem")}"
  filename = "${var.file_base}.key"
}
resource "local_file" "pub" {
  count = "${module.save.if_active}"
  content = "${lookup(var.tls,"public_key_pem")}"
  filename = "${var.file_base}.pub"
}

output "trigger" {
  value = "${join(",",concat(local_file.ca.*.id,local_file.cert.*.id,local_file.key.*.id,local_file.pub.*.id))}"
}

output "private_key_pem" {
  value = "${lookup(var.tls,"private_key_pem")}"
}

output "public_key_pem" {
  value = "${lookup(var.tls,"public_key_pem")}"
}

output "cert_pem" {
  value = "${lookup(var.tls,"cert_pem")}"
}

output "ca_cert" {
  value = "${lookup(var.tls,"ca_cert")}"
}

output "ca_key" {
  value = "${lookup(var.tls,"ca_key")}"
}


output "private_key_pem_b64" {
  value = "${base64encode(lookup(var.tls,"private_key_pem"))}"
}

output "public_key_pem_b64" {
  value = "${base64encode(lookup(var.tls,"public_key_pem"))}"
}

output "cert_pem_b64" {
  value = "${base64encode(lookup(var.tls,"cert_pem"))}"
}

output "ca_cert_b64" {
  value = "${base64encode(lookup(var.tls,"ca_cert"))}"
}

output "ca_key_b64" {
  value = "${base64encode(lookup(var.tls,"ca_key"))}"
}


output "tls" {
  value = "${var.tls}"
}

