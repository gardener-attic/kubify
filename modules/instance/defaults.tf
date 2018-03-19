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


variable "platform" {
}

module "bastion_vm" {
  source = "./../vms"

  platform = "${var.platform}"
  node_type = "bastion"
  default_flavor_name = "${var.flavor_name}"
  flavor_name = "${lookup(var.bastion,"flavor_name", var.bastion_flavor_name)}"

  default_image_name = "${module.versions.image_name}"
  image_name = "${lookup(var.bastion,"image_name", var.bastion_image_name)}"
}

module "master_vm" {
  source = "./../vms"

  platform = "${var.platform}"
  node_type = "master"
  default_flavor_name = "${var.flavor_name}"
  flavor_name = "${lookup(var.master,"flavor_name", var.master_flavor_name)}"

  default_image_name = "${module.versions.image_name}"
  image_name = "${lookup(var.master,"image_name", var.master_image_name)}"

}

module "worker_vm" {
  source = "./../vms"

  platform = "${var.platform}"
  node_type = "worker"
  default_flavor_name = "${var.flavor_name}"
  flavor_name = "${lookup(var.worker,"flavor_name",var.worker_flavor_name)}"

  default_image_name = "${module.versions.image_name}"
  image_name = "${lookup(var.worker,"image_name",var.worker_image_name)}"
}
