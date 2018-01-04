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


module "roll" {
  source = "../../../../modules/roll"

  state = "${var.state}"
  update_mode = "${var.update_mode}"

  size = "${var.node_count}"

  image_name = "${data.openstack_images_image_v2.image.id}"
  flavor_name = "${var.flavor_name}"
  cloud_init = "${var.cloud_init}"
}

output "state" {
  value ="${merge(module.roll.state,map("nodes", join(",",module.nodes.value)))}"
}

output "info" {
  value = "${module.roll.info}"
}


