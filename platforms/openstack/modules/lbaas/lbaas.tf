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
variable "vip_pool_name" {
  default = ""
}
variable "provider" {
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
module "pool" {
  source = "../../../../modules/flag"
  option = "${signum(length(var.vip_pool_name))}"
}

resource "openstack_lb_loadbalancer_v2" "lbaas" {
  count = "${module.lbaas.flag}"
  vip_subnet_id = "${module.vip.flag ? var.vip_subnet_id : var.member_subnet_id}"
#  region = "${var.os_region}"
  name = "${var.name}"
  loadbalancer_provider = "${var.provider}"
  description = "${var.description}"
}
resource "openstack_networking_floatingip_v2" "lbaas" {
  count = "${module.pool.flag * module.lbaas.flag}"
  pool = "${var.vip_pool_name}"
  port_id = "${openstack_lb_loadbalancer_v2.lbaas.vip_port_id}"
}

resource "openstack_lb_listener_v2" "lbaas" {
  count = "${module.lbaas.flag * length(var.ports)}"
  protocol        = "TCP"
  protocol_port   = "${element(var.ports,count.index)}"
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.lbaas.id}"
  name = "${var.name}"
  description = "${var.description} (Listener port ${element(var.ports,count.index)})"
}

resource "openstack_lb_pool_v2" "lbaas" {
  count = "${module.lbaas.flag * length(var.ports)}"
  name = "${var.name}"
  description = "${var.description} (Pool port ${element(var.ports,count.index)})"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${element(openstack_lb_listener_v2.lbaas.*.id,count.index)}"
#  loadbalancer_id = "${openstack_lb_loadbalancer_v2.lbaas.id}"
}

resource "openstack_lb_monitor_v2" "lbaas" {
  count = "${module.lbaas.flag * length(var.ports)}"
  depends_on = ["openstack_lb_pool_v2.lbaas"]
#  name = "${var.name}"
  pool_id     = "${element(openstack_lb_pool_v2.lbaas.*.id,count.index)}"
  type = "TCP"
  delay = 30
  timeout = 20
  max_retries = 2
}

resource "openstack_lb_member_v2" "lbaas" {
  count         = "${module.lbaas.flag * var.member_count * length(var.ports)}"
  #name          = "${var.name}-${count.index}"
  pool_id       = "${element(openstack_lb_pool_v2.lbaas.*.id, count.index / var.member_count)}"
  subnet_id     = "${var.member_subnet_id}"
  address       = "${element(var.members,count.index % var.member_count)}"
  protocol_port = "${element(var.ports,count.index / var.member_count)}"
}

module "address" {
  source = "../../../../modules/defaults"
  optional = true
  values = ["${openstack_networking_floatingip_v2.lbaas.*.address}"]
}

module "vip_address" {
  source = "../../../../modules/defaults"
  optional = true
  values = ["${openstack_lb_loadbalancer_v2.lbaas.*.vip_address}"]
}

output "vip_address" {
  value = "${module.pool.flag ? module.address.value : module.vip_address.value}"
}

output "vip_type" {
  value = "A"
}
