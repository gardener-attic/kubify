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


module "route53_dns_hostedzone" {
  source = "../../configurable"
  optional = "${! var.active}"
  value  = "${lookup(var.config,"hosted_zone_id")}"
}

locals {
  names = "${compact(concat(list(var.name),var.names))}"
}

resource "aws_route53_record" "record" {
  provider = "aws.route53"
  count    = "${var.active * length(local.names)}"
  zone_id  = "${module.route53_dns_hostedzone.value}"
  name     = "${element(local.names,count.index)}"
  type     = "${var.type}"
  ttl      = "${var.ttl}"
  records  = ["${var.target}"]
}
