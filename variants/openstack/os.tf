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


variable "os_user_name" {
  type = "string"
}
variable "os_tenant_name" {
  type = "string"
  default = ""
}
variable "os_tenant_id" {
  type = "string"
  default = ""
}
variable "os_domain_name" {
  type = "string"
  default = ""
}
variable "os_domain_id" {
  type = "string"
  default = ""
}
variable "os_password" {
  type = "string"
}
variable "os_auth_url" {
  type = "string"
}
variable "os_region" {
  type = "string"
}
variable "os_az" {
  type = "string"
}
variable "os_insecure" {
  default = true
}
variable "os_fip_pool_name" {
  type = "string"
}
variable "os_lbaas_subnet_id" {
  type = "string"
  default = ""
}
variable "os_lbaas_pool_name" {
  type = "string"
  default = ""
}
variable "os_lbaas_provider" {
  type = "string"
  default = ""
}
variable "os_device_name" {
  type = "string"
  default = ""
}


module "iaas_config" {
  source = "./modules/config"
  auth_url = "${var.os_auth_url}"
  availability_zone = "${var.os_az}"
  domain_name = "${var.os_domain_name}"
  domain_id = "${var.os_domain_id}"
  tenant_name = "${var.os_tenant_name}"
  tenant_id = "${var.os_tenant_id}"
  region = "${var.os_region}"
  user_name = "${var.os_user_name}"
  password = "${var.os_password}"
  insecure = "${var.os_insecure}"
  fip_pool_name = "${var.os_fip_pool_name}"
  lbaas_pool_name = "${var.os_lbaas_pool_name}"
  lbaas_subnet_id = "${var.os_lbaas_subnet_id}"
  lbaas_provider = "${var.os_lbaas_provider}"
  device_name = "${var.os_device_name}"
}

provider "openstack" {
#  version = "= 0.2.2"
  user_name   = "${var.os_user_name}"
  tenant_name = "${var.os_tenant_name}"
  domain_name = "${var.os_domain_name}"
  tenant_id   = "${var.os_tenant_id}"
  domain_id   = "${var.os_domain_id}"
  password    = "${var.os_password}"
  auth_url    = "${var.os_auth_url}"
  region      = "${var.os_region}"
  insecure    = "${var.os_insecure}"
}

locals {
  platform = "openstack"
  aws_defaults = { }
}

