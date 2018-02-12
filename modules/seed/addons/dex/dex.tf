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

################################################################
# special handling for monitoring addon
################################################################

variable "config" {
  type = "map"
}
variable "active" {
  type = "string"
}

variable "versions" {
  type = "map"
}
variable "standard" {
  type = "map"
}

variable "namespace" {
  default = "kube-system"
}

module "versions" {
  source = "../../../versions"
  versions = "${var.versions}"
}

variable "cluster-lb" {
  default = "false"
}

module "dex" {
  source = "../../../flag"
  option = "${var.active}"
}

locals {
  external-dns = "${var.cluster-lb}"
  dns-controller = "${local.external-dns ? "dns-controller" : "none"}"
}

#
# terraform workarround
# the lookup function onyl supports simple values and # the [] operator
# on maps supports complex types but only homogeneous entry structures
# Therefore we have to separate list values from map values from simple type values
# to be able to lookup dedicated settings.
#
module "config_maps" {
  source = "../../../lookup_map" 
  map = "${var.config}"
  key = "maps"
}
module "config_lists" {
  source = "../../../lookup_map" 
  map = "${var.config}"
  key = "lists"
}
module "config_values" {
  source = "../../../lookup_map" 
  map = "${var.config}"
  key = "values"
}

module "connectors" {
  source = "../../../lookup_list" 
  map = "${module.config_lists.value}"
  key = "connectors"
}

module "tls" {
  source = "../../../lookup_map" 
  map = "${module.config_maps.value}"
  key = "tls"
}

resource "random_id" "kubectl" {
  byte_length = 8
}
resource "random_id" "gardener" {
  byte_length = 8
}

data "template_file" "tls_secret" {
  count = "${contains(keys(module.config_maps.value),"tls") ? 1 : 0}"
  template= "${file("${path.module}/templates/tls_secret.yaml")}"
  vars {
    namespace = "${var.namespace}"
    tls_crt_b64 = "${lookup(module.tls.value,"cert")}"
    tls_key_b64 = "${lookup(module.tls.value,"key")}"
  }
}

module "tls_secret" {
  source = "../../../optrsc" 
  value = "${data.template_file.tls_secret.*.rendered}"
}

locals {
  connectors = "${module.connectors.value}"
  kubectl_client_id = "kube-kubectl"
  kubectl_client_secret = "${random_id.kubectl.b64_url}"
  gardener_client_secret = "${random_id.gardener.b64_url}"
}

output "connectors" {
  value = "${local.connectors}"
}

data "template_file" "connectors" {
  count = "${module.dex.if_active * length(local.connectors)}"
  template = "${file("${path.module}/templates/connectors/${lookup(local.connectors[count.index],"type")}.yaml")}"
  vars = {
    redirectURI=" https://${var.standard["identity"]}/callback"
    id = "${lookup(local.connectors[count.index],"id", lookup(local.connectors[count.index],"type"))}"
    name = "${lookup(local.connectors[count.index],"name", lookup(local.connectors[count.index],"id",lookup(local.connectors[count.index],"type")))}"
    ssoURL = "${lookup(local.connectors[count.index],"ssoURL","")}"
    ssoIssuer = "${lookup(local.connectors[count.index],"ssoIssuer","")}"
    entityIssuer = "${lookup(local.connectors[count.index],"entityIssuer","")}"
    ca_crt_b64 = "${base64encode(lookup(local.connectors[count.index],"ca_cert",""))}"
    orgs = "${lookup(local.connectors[count.index],"orgs","")}"
    client_id = "${lookup(local.connectors[count.index],"client_id","")}"
    client_secret = "${lookup(local.connectors[count.index],"client_secret","")}"
  }
}

locals {
  newline = "\n"
  connector_config = "${module.dex.if_active * length(local.connectors) > 0 ? "${local.newline}${join(local.newline,data.template_file.connectors.*.rendered)}" : ""}"

  dummy = {
    namespace = "${var.namespace}"
    dns-controller = ""
    dex_port = "5556"
    kubectl_client_id = ""
    kubectl_client_secret = ""
    gardener_client_secret = ""
    connectors = ""
  }

  default_values = {
    namespace = "${var.namespace}"
    dns-controller = "${local.dns-controller}"
    dex_port = "5556"
    version = "${module.versions.dex_version}"
    kubectl_client_id = "${local.kubectl_client_id}"
    kubectl_client_secret = "${local.kubectl_client_secret}"
    gardener_client_secret = "${local.gardener_client_secret}"
  }
  generated = {
    connectors = "${indent(6,local.connector_config)}"
    tls_secret = "${module.tls_secret.value}"
    #connectors = "test"
  }
}

output "connector_config" {
  value = "${local.connector_config}"
}

#
# addon module api
#
output "if_active" {
  value = "${module.dex.if_active}"
}

output "oidc" {
  value = {
    oidc-issuer-url = "https://${var.standard["identity"]}"
    oidc-client-id  = "${local.kubectl_client_id}"
    oidc-username-claim  = "email"
    oidc-groups-claim  = "groups"
  }
}

output "dummy" {
  value = "${local.dummy}"
}
output "defaults" {
  value="${local.default_values}"
}
output "generated" {
  value="${merge(local.generated,module.config_values.value)}"
}

output "manifests" {
  value="${path.module}/templates/manifests"
}

output "deploy" {
  value=""
}
