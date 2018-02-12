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


variable "target" {
  type = "string"
}
variable "type" {
  type = "string"
}
variable "name" {
  type = "string"
  default = ""
}
variable "names" {
  type = "list"
  default = [ ]
}
variable "ttl" {
  default = 300
}

variable "config" {
  type = "map"
}
variable "active" {
  default = false
}


module "active" {
  source = "../flag"
  option = "${var.active}"
}

module "dns" {
  source = "../value_check"
  value = "${lookup(var.config,"dns_type")}"
  values = [ "route53" ]
}

module "route53_dns" {
  source = "../flag"
  option = "${module.dns.value == "route53"}"
}

module "route53" {
  source = "./route53"

  active = "${module.active.if_active * module.route53_dns.if_active}"

  target = "${var.target}"
  type = "${var.type}"
  name = "${var.name}"
  names = "${var.names}"
  ttl = "${var.ttl}"

  config = "${var.config}"
}

