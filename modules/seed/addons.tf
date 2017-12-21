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


locals {
  addons_dir = "${path.module}/templates/addons"
}

#
# special monitoring
#

module "prometheus" {
  source = "../tls"

  file_base = "${var.tls_dir}/prometheus"
  common_name = "prometheus"
  organization = "${var.cluster_name}"
  ca = "${module.apiserver.ca_cert}"
  ca_key = "${module.apiserver.ca_key}"
  ip_addresses = []
  dns_names = [ "prometheus.${var.ingress_base_domain}" ]
}
module "prometheus_config" {
  source = "../file"
  path="${lookup(local.config["monitoring"],"prometheus_config_file","")}"
  prefix=<<EOF

EOF
}
module "prometheus_rules" {
  source = "../file"
  path="${lookup(local.config["monitoring"],"prometheus_rules_file","")}"
  prefix=<<EOF

EOF
}

module "grafana" {
  source = "../tls"

  file_base = "${var.tls_dir}/grafana"
  common_name = "grafana"
  organization = "${var.cluster_name}"
  ca = "${module.apiserver.ca_cert}"
  ca_key = "${module.apiserver.ca_key}"
  ip_addresses = []
  dns_names = [ "grafana.${var.ingress_base_domain}" ]
}

module "grafana_config" {
  source = "../file"
  path="${lookup(local.config["monitoring"],"grafana_config_file","")}"
  prefix=<<EOF

EOF
}

module "alertmanager" {
  source = "../tls"

  file_base = "${var.tls_dir}/alertmanager"
  common_name = "alertmanager"
  organization = "${var.cluster_name}"
  ca = "${module.apiserver.ca_cert}"
  ca_key = "${module.apiserver.ca_key}"
  ip_addresses = []
  dns_names = [ "alertmanager.${var.ingress_base_domain}" ]
}

module "alertmanager_config" {
  source = "../file"
  path="${lookup(local.config["monitoring"],"alertmanager_config_file","")}"
}

data "template_file" "alertmanager_config" {
  template="${file("${local.addons_dir}/monitoring/alertmanager-config.yaml")}"
  vars {
  }
}

locals {
  alertmanager_default_b64="${base64encode(data.template_file.alertmanager_config.rendered)}"
  alertmanager_config_b64="${base64encode(module.alertmanager_config.content==""?data.template_file.alertmanager_config.rendered:module.alertmanager_config.content)}"
}

#
# generic addon handling
#

#
# to add an addon add an appropriate entry to local.defaultconfig and append the key to local.addons
#

# for some unknown reasons locals cannot be used here
variable "slash" {
  default = "\""
}

module "iaas-addons" {
  source = "../variable"
  value = "${length(var.addon_dirs) > 0 ? "${var.slash}${join("${var.slash} ${var.slash}", var.addon_dirs)}${var.slash}" : ""}"
}

locals {
  # this an explicit array to keep a distinct order for the multi-resource
  addons = [ "dashboard", "nginx-ingress", "fluentd-elasticsearch", "kube-lego", "heapster", "monitoring", "guestbook" ]

  empty = {
     "dashboard" = { }
     "heapster" = { }
     "nginx-ingress" = { }
     "kube-lego" = { }
     "fluentd-elasticsearch" = {}
     "monitoring" = { }
     "guestbook" = { }
  }

  defaults = {
     "dashboard" = {
       basic_auth_b64 = "${module.dashboard_creds.b64}"
     }
     "nginx-ingress" = {
        version = "${module.versions.nginx_version}"
     }
     "fluentd-elasticsearch" = {}
     "heapster" = {}
     "kube-lego" = {
       version = "${module.versions.lego_version}"
     }
     "monitoring" = {
       basic_auth_b64 = "${module.dashboard_creds.b64}"

       prometheus_crt_b64 = "${module.prometheus.cert_pem_b64}"
       prometheus_key_b64 = "${module.prometheus.private_key_pem_b64}"
       prometheus_volume_size = "20Gi"

       grafana_crt_b64 = "${module.grafana.cert_pem_b64}"
       grafana_key_b64 = "${module.grafana.private_key_pem_b64}"

       alertmanager_crt_b64 = "${module.alertmanager.cert_pem_b64}"
       alertmanager_key_b64 = "${module.alertmanager.private_key_pem_b64}"
       alertmanager_config_b64 = "${local.alertmanager_default_b64}"
       alertmanager_volume_size = "10Gi"
     }
     "guestbook" = {}
  }

  generated = {
    "monitoring" = {
       grafana_config = "${module.grafana_config.content}"
       prometheus_config = "${module.prometheus_config.content}"
       prometheus_rules = "${module.prometheus_rules.content}"
       alertmanager_config_b64 = "${local.alertmanager_config_b64}"
    }
  }

  dummy = {
     dummy = {
       basic_auth_b64 = ""
       email = ""
       version = ""
       prometheus_config = ""
       prometheus_rules = ""
       prometheus_crt_b64 = "${module.prometheus.cert_pem_b64}"
       prometheus_key_b64 = "${module.prometheus.private_key_pem_b64}"
       prometheus_volume_size = "20Gi"

       grafana_config = ""
       grafana_crt_b64 = "${module.grafana.cert_pem_b64}"
       grafana_key_b64 = "${module.grafana.private_key_pem_b64}"

       alertmanager_crt_b64 = "${module.alertmanager.cert_pem_b64}"
       alertmanager_key_b64 = "${module.alertmanager.private_key_pem_b64}"
       alertmanager_config_b64 = "${local.alertmanager_default_b64}"
       alertmanager_volume_size = "10Gi"
     }
  }

  selected = "${keys(var.addons)}"
  config = "${merge(local.empty, local.dummy, var.addons)}"

  defaultconfig = "${merge(local.empty, local.defaults)}"
  generatedconfig = "${merge(local.empty, local.generated)}"
  standard = {
    cluster_name = "${var.cluster_name}"
    ingress = "${var.ingress_base_domain}"
  }
}

#
# the templates are always processed for all possible extensions, always in the same
# order, this allows to use a counted resource, even if then actual set of addons
# changes without potentials recreation because of the index change of an addon.
#
# the dummy config defines null values for all template vars for all addons
# It is used ONLY if the addon is inactive, this prevents errors comming from the template.
# If the addon is used only the defaults are merged, this will cause errors if
# a mandatory configuration variable for an extension is missing
#

resource "template_dir" "addons" {
  count = "${length(local.addons)}"

  source_dir = "${local.addons_dir}/${local.addons[count.index]}"
  destination_dir = "${var.gen_dir}/addons/${local.addons[count.index]}"

  vars = "${merge(local.standard,local.defaultconfig[local.addons[count.index]],local.generatedconfig[local.addons[count.index]],local.config[contains(local.selected, local.addons[count.index]) ? local.addons[count.index] : "dummy"])}"
}

output "addon-config" {
  value = "${local.config}"
}
