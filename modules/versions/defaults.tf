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

###############################################################
# versions
###############################################################

locals {
  image_name                 = "coreos-1855.4.0"
  bastion_image_name         = "ubuntu-16.04"
  kubernetes_version         = "v1.10.12"
  dns_version                = "1.14.5"
  flannel_version            = "v0.9.1"
  cni_version                = "0.3.0"
  etcd_version               = "v3.3.10"
  etcd_image                 = "quay.io/coreos/etcd"
  etcd_operator_version      = "v0.6.1"
  etcd_backup_version        = "0.3.0"
  etcd_backup_image          = "eu.gcr.io/gardener-project/gardener/etcdbrctl"
  self_bootkube_version      = "v0.8.2"
  self_bootkube_image        = "quay.io/coreos/bootkube"
  bootkube_version           = "v0.13.0"
  bootkube_image             = "quay.io/coreos/bootkube"
  kubernetes_hyperkube       = "gcr.io/google_containers/hyperkube"
  kubernetes_hyperkube_patch = ""
  nginx_version              = "0.17.1"

  lego_version = "0.1.5"
  dex_version  = "v2.6.1"

  dashboard_image   = "gcr.io/google_containers/kubernetes-dashboard-amd64"
  dashboard_version = "v1.10.0"

  garden_apiserver_image    = "eu.gcr.io/gardener-project/gardener/apiserver"
  garden_apiserver_version  = "0.1.0-0628e0bdd679351378c05503cf1de301a79a1b2a"
  garden_controller_image   = "eu.gcr.io/gardener-project/gardener/controller-manager"
  garden_controller_version = "0.1.0-0628e0bdd679351378c05503cf1de301a79a1b2a"

  external_dns_image   = "mandelsoft/external-dns"
  external_dns_version = "v0.4.8-ms-3"

  machine_controller_image   = "eu.gcr.io/gardener-project/gardener/machine-controller-manager"
  machine_controller_version = "0.1.0-0f9d4de017c78f550f1153b83dc70807855df396"

  tiller_version = "v2.7.2"
  tiller_image   = "gcr.io/kubernetes-helm/tiller"
  helm_version   = "v0.2.1"
  helm_image     = "bitnami/helm-crd-controller"
}
