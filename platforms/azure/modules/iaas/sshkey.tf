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


resource "tls_private_key" "ssh_key" {
  algorithm   = "RSA"
  rsa_bits    = "4096"
}

resource "local_file" "private_key" {
  content     = "${tls_private_key.ssh_key.private_key_pem}"
  filename = "${var.gen_dir}/nodes_privatekey.pem"
}

resource "null_resource" "set_private_key_mode" {
  provisioner "local-exec" {
    command = "chmod 0600 ${local_file.private_key.filename}"
  }
}

output "public_key" {
  value = "${tls_private_key.ssh_key.public_key_pem}"
}
output "private_key" {
  value = "${tls_private_key.ssh_key.private_key_pem}"
}
output "key" {
  value = "${tls_private_key.ssh_key.public_key_openssh}"
}
