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

locals {
  monitoring = "${local.config["monitoring"]}"
  monitoring_active = "${contains(keys(var.addons),"monitoring") ? 1 : 0}"
}

#
# prometheus
#
module "prometheus" {
  source = "../tls"
  active = "${local.monitoring_active}"

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
  path="${lookup(local.monitoring,"prometheus_config_file","")}"
  prefix=<<EOF

EOF
}

data "template_file" "prometheus_config" {
  template="${file("${module.addons_dir.value}/monitoring/prometheus-config.yaml")}"
  vars {
  }
}

locals {
  prometheus_default_indent="${indent(6,data.template_file.prometheus_config.rendered)}"
  prometheus_config_indent="${indent(6,module.prometheus_config.content==""?data.template_file.prometheus_config.rendered:module.prometheus_config.content)}"
}

module "prometheus_rules" {
  source = "../file"
  path="${lookup(local.monitoring,"prometheus_rules_file","")}"
  prefix=<<EOF

EOF
}

data "template_file" "prometheus_rules" {
  template="${file("${module.addons_dir.value}/monitoring/prometheus-rules.yaml")}"
  vars {
  }
}

locals {
  prometheus_rules_default_indent="${indent(2,data.template_file.prometheus_rules.rendered)}"
  prometheus_rules_indent="${indent(2,module.prometheus_rules.content==""?data.template_file.prometheus_rules.rendered:module.prometheus_rules.content)}"
}

#
# grafana
#
module "grafana" {
  source = "../tls"
  active = "${local.monitoring_active}"

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
  path="${lookup(local.monitoring,"grafana_config_file","")}"
  prefix=<<EOF

EOF
}

data "template_file" "grafana_config" {
  template="${file("${module.addons_dir.value}/monitoring/grafana-config.yaml")}"
  vars {
  }
}

locals {
  grafana_config_default_indent="${indent(2,data.template_file.grafana_config.rendered)}"
  grafana_config_indent="${indent(2,module.grafana_config.content==""?data.template_file.grafana_config.rendered:module.grafana_config.content)}"
}

#
# alertmanager
#
module "alertmanager" {
  source = "../tls"
  active = "${local.monitoring_active}"

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
  path="${lookup(local.monitoring,"alertmanager_config_file","")}"
}

data "template_file" "alertmanager_config" {
  template="${file("${module.addons_dir.value}/monitoring/alertmanager-config.yaml")}"
  vars {
  }
}

locals {
  alertmanager_default_b64="${base64encode(data.template_file.alertmanager_config.rendered)}"
  alertmanager_config_b64="${base64encode(module.alertmanager_config.content==""?data.template_file.alertmanager_config.rendered:module.alertmanager_config.content)}"
}


module "monitoring_defaults" {
  source = "../mapvar"
  value = {
     basic_auth_b64 = "${module.dashboard_creds.b64}"

     prometheus_config = "${local.prometheus_config_indent}"
     prometheus_rules = "${local.prometheus_rules_indent}"
     prometheus_crt_b64 = "${module.prometheus.cert_pem_b64}"
     prometheus_key_b64 = "${module.prometheus.private_key_pem_b64}"
     prometheus_volume_size = "20Gi"

     grafana_config = "${local.grafana_config_indent}"
     grafana_crt_b64 = "${module.grafana.cert_pem_b64}"
     grafana_key_b64 = "${module.grafana.private_key_pem_b64}"

     alertmanager_crt_b64 = "${module.alertmanager.cert_pem_b64}"
     alertmanager_key_b64 = "${module.alertmanager.private_key_pem_b64}"
     alertmanager_config_b64 = "${local.alertmanager_default_b64}"
     alertmanager_volume_size = "10Gi"
  }
}

module "monitoring_generated" {
  source = "../mapvar"
  value = {
     grafana_config = "${local.grafana_config_indent}"
     prometheus_config = "${local.prometheus_config_indent}"
     prometheus_rules = "${local.prometheus_rules_indent}"
     alertmanager_config_b64 = "${local.alertmanager_config_b64}"
  }
}

module "monitoring_dummy" {
  source = "../mapvar"
  value = {
     prometheus_config = "${local.prometheus_default_indent}"
     prometheus_rules = "${local.prometheus_rules_default_indent}"
     prometheus_crt_b64 = "${module.prometheus.cert_pem_b64}"
     prometheus_key_b64 = "${module.prometheus.private_key_pem_b64}"
     prometheus_volume_size = "20Gi"

     grafana_config = "${local.grafana_config_default_indent}"
     grafana_crt_b64 = "${module.grafana.cert_pem_b64}"
     grafana_key_b64 = "${module.grafana.private_key_pem_b64}"

     alertmanager_crt_b64 = "${module.alertmanager.cert_pem_b64}"
     alertmanager_key_b64 = "${module.alertmanager.private_key_pem_b64}"
     alertmanager_config_b64 = "${local.alertmanager_default_b64}"
     alertmanager_volume_size = "10Gi"
  }
}

output "grafana_config" {
  value="${local.grafana_config_indent}"
}
output "prometheus_config" {
  value="${local.prometheus_default_indent}"
}
output "prometheus_rules" {
  value="${local.prometheus_rules_indent}"
}
output "alertmanager_config_b64" {
  value="${local.alertmanager_config_b64}"
}
