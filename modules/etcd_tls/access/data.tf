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


variable "tls" {
  type = "map"
}

module "peer" {
  source = "../../tls/access"
  tls = "${var.tls["peer"]}"
}

module "server" {
  source = "../../tls/access"
  tls = "${var.tls["server"]}"
}


# server

output "server_private_key_pem" {
  value = "${module.server.private_key_pem}"
}

output "server_public_key_pem" {
  value = "${module.server.public_key_pem}"
}

output "server_cert_pem" {
  value = "${module.server.cert_pem}"
}

output "server_ca_cert" {
  value = "${module.server.ca_cert}"
}

output "server_ca_key" {
  value = "${module.server.ca_key}"
}


output "server_private_key_pem_b64" {
  value = "${module.server.private_key_pem_b64}"
}

output "server_public_key_pem_b64" {
  value = "${module.server.public_key_pem_b64}"
}

output "server_cert_pem_b64" {
  value = "${module.server.cert_pem_b64}"
}

output "server_ca_cert_b64" {
  value = "${module.server.ca_cert_b64}"
}

output "server_ca_key_b64" {
  value = "${module.server.ca_key_b64}"
}


# peer

output "peer_private_key_pem" {
  value = "${module.peer.private_key_pem}"
}

output "peer_public_key_pem" {
  value = "${module.peer.public_key_pem}"
}

output "peer_cert_pem" {
  value = "${module.peer.cert_pem}"
}

output "peer_ca_cert" {
  value = "${module.peer.ca_cert}"
}

output "peer_ca_key" {
  value = "${module.peer.ca_key}"
}


output "peer_private_key_pem_b64" {
  value = "${module.peer.private_key_pem_b64}"
}

output "peer_public_key_pem_b64" {
  value = "${module.peer.public_key_pem_b64}"
}

output "peer_cert_pem_b64" {
  value = "${module.peer.cert_pem_b64}"
}

output "peer_ca_cert_b64" {
  value = "${module.peer.ca_cert_b64}"
}

output "peer_ca_key_b64" {
  value = "${module.peer.ca_key_b64}"
}


