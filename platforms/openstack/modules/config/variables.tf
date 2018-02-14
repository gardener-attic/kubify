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

variable "user_name" {
  type = "string"
  default = ""
}
variable "availability_zone" {
  type = "string"
  default = ""
}
variable "volume_zone" { # default: availability_zone
  type = "string"
  default = ""
}
variable "tenant_name" {
  type = "string"
  default = ""
}
variable "tenant_id" {
  type = "string"
  default = ""
}
variable "domain_name" {
  type = "string"
  default = ""
}
variable "domain_id" {
  type = "string"
  default = ""
}
variable "password" {
  type = "string"
  default = ""
}
variable "auth_url" {
  type = "string"
  default = ""
}
variable "region" {
  type = "string"
  default = ""
}
variable "insecure" {
  default = true
}
variable "cacert" {
  default = ""
}

variable "fip_pool_name" {
  default = ""
}
variable "lbaas_subnet_id" {
  default = ""
}
variable "lbaas_pool_name" {
  default = ""
}
variable "lbaas_provider" {
  default = ""
}
variable "device_name" {
  default = ""
}

