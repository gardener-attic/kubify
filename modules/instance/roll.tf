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

###########################################
# state handling
#

resource "local_file" "state" {
  content     = <<EOF
{
  "worker_state": ${jsonencode(module.worker.state)},
  "master_state": ${jsonencode(module.master.state)},
  "recovery_version": "${module.recovery_version.value}"
}
EOF

  filename = "${path.cwd}/state.auto.tfvars"
}

output "master_roll_info" {
  value = "${module.master.info}"
}
output "worker_roll_info" {
  value = "${module.worker.info}"
}

resource "local_file" "rollinfo" {
  content     = <<EOF
  {
    "master": ${jsonencode(module.master.info)}
    "worker": ${jsonencode(module.worker.info)}
    "recovery": "${module.recovery_version.value}"
  }
EOF
  filename = "${path.cwd}/rollinfo"
}

