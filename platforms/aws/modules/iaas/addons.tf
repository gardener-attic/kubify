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


resource "template_dir" "addons" {
  source_dir = "${path.module}/templates/addons"
  destination_dir = "${var.gen_dir}/iaas-addons"

  vars {
    kube2iam_version = "${module.kube2iam_version.value}"
    worker_role_arn = "${aws_iam_role.worker.arn}"
  }
}

output "addon-dirs" {
  value = [ "${var.gen_dir}/iaas-addons" ]
}
output "addon-trigger" {
  value = "${template_dir.addons.id}"
}
