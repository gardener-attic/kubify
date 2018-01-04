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

resource "aws_eip" "nodes" {
  count = "${module.fips.value}"
  vpc = true
}

resource "aws_eip_association" "eip_assoc" {
  count = "${module.fips.value}"
  instance_id = "${element(module.nodes.value,count.index)}"
  allocation_id = "${element(aws_eip.nodes.*.id,count.index)}"
}

output "fips" {
  value = ["${aws_eip.nodes.*.public_ip}"]
}

