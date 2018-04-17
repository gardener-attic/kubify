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


module "kubelet" {
  source = "../tls/access"
  tls = "${var.tls_kubelet}"
}
module "apiserver" {
  source = "../tls/access"
  tls = "${var.tls_apiserver}"
}
module "aggregator" {
  source = "../tls/access"
  tls = "${var.tls_aggregator}"
}
module "etcd" {
  source = "../etcd_tls/access"
  tls = "${var.tls_etcd}"
  tls_dir = "${module.selfhosted_etcd.if_active ? "" : "${var.gen_dir}/etcdtls/etcd"}" 
}
module "etcd-client" {
  source = "../tls/access"
  tls = "${var.tls_etcd_client}"
  file_base = "${module.selfhosted_etcd.if_active ? "" : "${var.gen_dir}/etcdtls/etcd-client"}" 
}

