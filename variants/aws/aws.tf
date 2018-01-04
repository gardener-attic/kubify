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


variable "aws_access_key" {
  type = "string"
}
variable "aws_secret_key" {
  type = "string"
}
variable "aws_region" {
  type = "string"
}
variable "aws_availability_zone" {
  type = "string"
}
variable "aws_vpc_cidr" {
  type = "string"
  default = "10.250.0.0/16"
}
variable "aws_public_subnet_cidr" {
  type = "string"
  default = ""
}


variable "aws_kube2iam_version" {
  type = "string"
  default = ""
}
variable "aws_kube2iam_roles" {
  type = "list"
  default = []
}

module "iaas_config" {
  source = "./modules/config"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
  availability_zone = "${var.aws_availability_zone}"
  vpc_cidr = "${var.aws_vpc_cidr}"
  public_subnet_cidr = "${var.aws_public_subnet_cidr}"

  kube2iam_version = "${var.aws_kube2iam_version}"
  kube2iam_roles = "${var.aws_kube2iam_roles}"
}

provider "aws" {
#  version = "= 0.2.2"
  access_key   = "${var.aws_access_key}"
  secret_key   = "${var.aws_secret_key}"
  region      = "${var.aws_region}"
}

locals {
  platform = "aws"
}

