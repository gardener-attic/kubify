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


# select one of target or targets.
# if targets is selected, the names argument must be set with identical size
#   and the entry_count parameter must be explicitly set to the length of the array
#   using a simple expression applicable for resource counts.
#   This is required because terraform is not always be able to determine the
#   length of the targets array for setting the resource count
# if target is selected, the names attibute might be set instead of then
#   name attribute to create multiple dns records for the same target.
#   In this case the name_count attribute must be set using a simple expression
#   applicable for resource counts.

variable "entry_count" {
  default = 0
}
variable "name_count" {
  default = 1
}
variable "target" {
  type = "string"
  default = ""
}
variable "targets" {
  type = "list"
  default = []
}
variable "name" {
  type = "string"
  default = ""
}
variable "names" {
  type = "list"
  default = [ ]
}

variable "type" {
  type = "string"
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
  values = [ "route53", "designate" ]
}

module "route53_dns" {
  source = "../flag"
  option = "${module.dns.value == "route53"}"
}

module "route53" {
  source = "./route53"

  active = "${module.active.if_active * module.route53_dns.if_active}"

  entry_count  = "${var.entry_count}"
  name_count  = "${var.name_count}"
  target = "${var.target}"
  targets= "${var.targets}"
  type   = "${var.type}"
  name   = "${var.name}"
  names  = "${var.names}"
  ttl    = "${var.ttl}"

  config = "${var.config}"
}

module "os_dns" {
  source = "../flag"
  option = "${module.dns.value == "designate"}"
}

module "designate" {
  source = "./designate"

  active = "${module.active.if_active * module.os_dns.if_active}"

  entry_count  = "${var.entry_count}"
  name_count  = "${var.name_count}"
  target = "${var.target}"
  targets= "${var.targets}"
  type   = "${var.type}"
  name   = "${var.name}"
  names  = "${var.names}"
  ttl    = "${var.ttl}"

  config = "${var.config}"
}
