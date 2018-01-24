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


variable "az_tenant_id" {
  type = "string"
}
variable "az_subscription_id" {
  type = "string"
}
variable "az_client_id" {
  type = "string"
}
variable "az_client_secret" {
  type = "string"
}
variable "az_region" {
  type = "string"
}
variable "az_cloudenv" {
  type = "string"
  default = "public"
}


provider "azurerm" {
  version = "0.1.5"
  tenant_id = "${var.az_tenant_id}"
  subscription_id = "${var.az_subscription_id}"
  client_id = "${var.az_client_id}"
  client_secret = "${var.az_client_secret}"
}

module "iaas_config" {
  source = "./modules/config"
  tenant_id = "${var.az_tenant_id}"
  subscription_id = "${var.az_subscription_id}"
  client_id = "${var.az_client_id}"
  client_secret = "${var.az_client_secret}"

  region = "${var.az_region}"
  cloudenv = "${var.az_cloudenv}"
}

locals {
  platform = "azure"
  aws_defaults = { }
}

