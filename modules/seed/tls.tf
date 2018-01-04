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


module "kubelet" {
  source = "../tls/access"
  tls = "${var.tls_kubelet}"
}
module "apiserver" {
  source = "../tls/access"
  tls = "${var.tls_apiserver}"
}
module "etcd" {
  source = "../etcd_tls/access"
  tls = "${var.tls_etcd}"
}
module "etcd-client" {
  source = "../tls/access"
  tls = "${var.tls_etcd_client}"
}

