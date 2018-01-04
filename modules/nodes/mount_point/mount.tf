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

variable "device" {
  type = "string"
}
variable "path" {
  type = "string"
}
variable "use" {
  default = 1
}

# in replace a "/" leads to a syntax highlighting error in vi
variable "slash" {
  default = "/"
}

data "template_file" "mount" {
  template = "${file("${path.module}/templates/volume.mount")}"
  
  vars {
    name = "${substr(replace(var.path, var.slash, "-" ),1,-1)}"
    path = "${var.path}"
    device = "${var.device}"
  }
}

output "entry" {
  value = "${var.use ? data.template_file.mount.rendered : ""}"
}
