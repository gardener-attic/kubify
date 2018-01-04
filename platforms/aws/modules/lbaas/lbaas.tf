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

variable "vpc_id" {
}
variable "security_groups" {
  type = "list"
}
variable "name" {
}
variable "use_lbaas" {
  default = "1"
}
variable "description" {
  default = ""
}


variable "member_subnet_id" {
}
variable "vip_subnet_id" {
  default = ""
}

variable "ports" {
  type = "list"
  default = [ "443" ]
}

variable "members" {
  type = "list"
}
variable "member_count" {
  type = "string"
}

module "lbaas" {
  source = "../../../../modules/flag"
  option = "${var.use_lbaas}"
}
module "vip" {
  source = "../../../../modules/flag"
  option = "${signum(length(var.vip_subnet_id))}"
}


resource "aws_elb" "lbaas-1" {
  count   = "${module.lbaas.flag * ( length(var.ports) == 1 ? 1 : 0 )}"
  name    = "${var.name}"

  internal        = false
  security_groups = [ "${var.security_groups}" ]
  subnets         = ["${var.vip_subnet_id}"]

  listener {
   lb_port = "${element(var.ports,0)}"
   lb_protocol = "TCP"
   instance_port = "${element(var.ports,0)}"
   instance_protocol = "TCP"
  }

  health_check {
    timeout = 4
    interval = 5
    healthy_threshold = 2
    unhealthy_threshold = 2

    target = "TCP:${element(var.ports,0)}"
  }

  tags {
    Name = "${var.name}"
  }
}

resource "aws_elb" "lbaas-2" {
  count   = "${module.lbaas.flag * ( length(var.ports) == 2 ? 1 : 0 )}"
  name    = "${var.name}"

  internal        = false
  security_groups = [ "${var.security_groups}" ]
  subnets         = ["${var.vip_subnet_id}"]

  listener {
   lb_port = "${element(var.ports,0)}"
   lb_protocol = "TCP"
   instance_port = "${element(var.ports,0)}"
   instance_protocol = "TCP"
  }
  listener {
   lb_port = "${element(var.ports,1)}"
   lb_protocol = "TCP"
   instance_port = "${element(var.ports,1)}"
   instance_protocol = "TCP"
  }

  health_check {
    timeout = 4
    interval = 5
    healthy_threshold = 2
    unhealthy_threshold = 2

    target = "TCP:${element(var.ports,0)}"
  }

  tags {
    Name = "${var.name}"
  }
}

module "elb" {
  source = "../../../../modules/variable"
  value = "${element(concat(aws_elb.lbaas-1.*.dns_name,aws_elb.lbaas-2.*.dns_name,list("")),0)}"
}

resource "local_file" "elb-name" {
  count = 0
  filename = "elb-${var.name}.txt"
  content = "${module.elb.value}"
}

resource "aws_elb_attachment" "lbaas" {
  count         = "${module.lbaas.flag * var.member_count}"
#  elb           = "${module.elb.value}"
  elb           = "${var.name}"
  instance      = "${element(var.members,count.index)}"
}

output "vip_address" {
  value = "${module.elb.value}"
}
output "vip_type" {
  value = "CNAME"
}
