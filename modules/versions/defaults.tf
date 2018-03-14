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

###############################################################
# versions
###############################################################

locals {
  image_name                 = "coreos-1520.6.0"
  bastion_image_name         = "ubuntu-16.04"
  kubernetes_version         = "v1.9.3"
  dns_version                = "1.14.5"
  flannel_version            = "v0.9.1"
  cni_version                = "0.3.0"
  etcd_version               = "v3.1.8"
  etcd_operator_version      = "v0.6.1"
  bootkube_version           = "v0.8.2"
  bootkube                   = "quay.io/coreos/bootkube"
  kubernetes_hyperkube       = "gcr.io/google_containers/hyperkube"
  kubernetes_hyperkube_patch = ""
  nginx_version              = "0.9.0"

  lego_version = "0.1.5"
  dex_version  = "v2.6.1"

  dashboard_image   = "gcr.io/google_containers/kubernetes-dashboard-amd64"
  dashboard_version = "v1.8.3"

  garden_apiserver_image    = "eu.gcr.io/gardener-project/gardener/apiserver"
  garden_apiserver_version  = "0.1.0-8446cd54eef1514992757f944850fdc34aa42c83"
  garden_controller_image   = "eu.gcr.io/gardener-project/gardener/controller-manager"
  garden_controller_version = "0.1.0-8446cd54eef1514992757f944850fdc34aa42c83"

  external_dns_image   = "mandelsoft/external-dns"
  external_dns_version = "v0.4.8-ms-3"

  machine_controller_image   = "eu.gcr.io/gardener-project/gardener/machine-controller-manager"
  machine_controller_version = "0.1.0-0f9d4de017c78f550f1153b83dc70807855df396"

  tiller_version = "v2.7.2"
  tiller_image   = "gcr.io/kubernetes-helm/tiller"
  helm_version   = "v0.2.1"
  helm_image     = "bitnami/helm-crd-controller"
}
