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


variable "dns" {
  type = "map"
}

module "hosted_zone_domain" {
  source = "./../variable"
  value = "${lookup(var.dns,"hosted_zone_domain","k8s.sapcloud.io")}"
}
module "base_domain" {
  source = "./../variable"
  value = "${lookup(var.dns,"base_domain","${var.base_domain}")}"
}
module "domain_name" {
  source = "./../variable"
  value = "${lookup(var.dns,"domain_name","${var.domain_name}")}"
}

#
# dns implementations
#

module "configure_additional_dns" {
  source = "./../flag"
  option = "${var.configure_additional_dns}"
}

module "apiserver_record" {
  source = "./../dns"

  config = "${var.dns}"

  active = "${module.provide_lbaas.value}"
  names  = "${slice(module.cluster.api_domains, 0,  (module.configure_additional_dns.flag ? 1 + length(var.additional_domains) : 1))}"
  type   = "${module.vip_type_apiserver.value}"
  ttl    = "300"
  target = "${module.vip_apiserver.value}"
}

module "ingress_record" {
  source = "./../dns"

  config = "${var.dns}"

  active = "${module.provide_lbaas_ingress.value}"
  names  = "${slice(module.cluster.ingress_domains, 0,  (module.configure_additional_dns.flag ? 1 + length(var.additional_domains) : 1))}"
  type   = "${module.vip_type_nginx.value}"
  ttl    = "300"
  target = "${module.vip_nginx.value}"
}

module "bastion_record" {
  source = "./../dns"

  config = "${var.dns}"

  active = "${var.use_bastion}"
  name   = "${module.cluster.bastion}"
  type   = "A"
  ttl    = "300"
  target = "${module.iaas.bastion}"
}

module "identity_record" {
  source = "./../dns"

  config = "${var.dns}"

  active = "${module.provide_lbaas_ingress.value}"
  name   = "${module.cluster.identity}"
  type   = "${module.vip_type_nginx.value}"
  ttl    = "300"
  target = "${module.vip_nginx.value}"
}


