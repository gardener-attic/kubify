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


##########################################
# floating ips
#

module "fips" {
  source = "../../../../modules/flag"
  option = "${var.provide_fips}"
  on = "${var.node_count}"
  off = "0"
  map = {
    single = "1"
  }
}  

resource "openstack_networking_floatingip_v2" "nodes" {
  count = "${module.fips.flag}"
  pool = "${module.os.fip_pool_name}"
}

resource "openstack_compute_floatingip_associate_v2" "nodes" {
  count = "${module.fips.value}"
  floating_ip = "${element(openstack_networking_floatingip_v2.nodes.*.address,count.index)}"
  instance_id = "${element(module.nodes.value,count.index)}"
}

output "fips" {
  value = ["${openstack_networking_floatingip_v2.nodes.*.address}"]
}

