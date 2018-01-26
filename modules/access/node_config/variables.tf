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

variable "count" {
  type = "string"
  default = ""
}

variable "image_name" {
  type = "string"
  default = ""
}

variable "flavor_name" {
  type = "string"
  default = ""
}

variable "user_name" {
  type = "string"
  default = ""
}

variable "update_mode" {
  type = "string"
  default = ""
}

variable "generation" {
  type = "string"
  default = ""
}

variable "assign_fips" {
  type = "string"
  default = ""
}

variable "root_volume_size" {
  type = "string"
  default = ""
}

variable "volume_size" {
  type = "string"
  default = ""
}
