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

module "s3_etcd_backup" {
  source = "../flag"
  option = "${module.etcd_backup.value == "s3"}"
}

module "s3_etcd_backup_access" {
  source      = "../access/aws"
  access_info = "${var.access_info["s3_etcd_backup"]}"
}

module "s3_etcd_backup_bucket" {
  source  = "../configurable"
  value   = "${lookup(var.etcd_backup,"bucket","")}"
  default = "etcd-${var.domain_name}"
}

module "s3_etcd_backup_prefix" {
  source   = "../template_input"
  template = "${lookup(var.etcd_backup,"prefix","")}"
  default  = "${module.s3_etcd_backup_bucket.if_configured ? "${var.domain_name}/etcd-operator" : "etcd-operator"}"

  variables = {
    domain_name  = "${var.domain_name}"
    cluster_name = "${var.cluster_name}"
  }
}

locals {
  s3_backup_vars = {
    access_key = "${module.s3_etcd_backup_access.access_key}"
    secret_key = "${module.s3_etcd_backup_access.secret_key}"
    region     = "${module.s3_etcd_backup_access.region}"
  }
}

data "template_file" "s3_credentials" {
  count    = "${module.s3_etcd_backup.if_active}"
  template = "${file("${path.module}/templates/etcd_backup/s3/credentials")}"
  vars     = "${local.s3_backup_vars}"
}

data "template_file" "s3_config" {
  count    = "${module.s3_etcd_backup.if_active}"
  template = "${file("${path.module}/templates/etcd_backup/s3/config")}"
  vars     = "${local.s3_backup_vars}"
}

data "template_file" "s3_secret" {
  count    = "${module.s3_etcd_backup.if_active}"
  template = "${file("${path.module}/templates/etcd_backup/s3/secret.yaml")}"

  vars {
    name        = "etcd-backup"
    namespace   = "kube-system"
    credentials = "${base64encode(data.template_file.s3_credentials.rendered)}"
    config      = "${base64encode(data.template_file.s3_config.rendered)}"
  }
}

data "template_file" "s3_etcd_backup_spec" {
  count    = "${module.s3_etcd_backup.if_active}"
  template = "${file("${path.module}/templates/etcd_backup/s3/spec.json")}"

  vars {
    bucket = "${module.s3_etcd_backup_bucket.value}"
    secret = "etcd-backup"
    prefix = "${module.s3_etcd_backup_prefix.value}"
  }
}

resource "local_file" "s3_etcd_backup_secret" {
  count    = "${module.s3_etcd_backup.if_active}"
  content  = "${data.template_file.s3_secret.rendered}"
  filename = "${module.distinct_manifests.value}/etcd-backup-secret.yaml"
}

resource "local_file" "s3_etcd_backup_spec" {
  count    = "${module.s3_etcd_backup.if_active}"
  content  = "{ \"spec\": { \n${data.template_file.s3_etcd_backup_spec.rendered}}}"
  filename = "${module.etcd_backup_spec.value}"
}

resource "aws_s3_bucket" "s3_etcd_backup" {
  count         = "${module.s3_etcd_backup_bucket.if_defaulted * module.s3_etcd_backup.if_active}"
  provider      = "aws.s3_etcd_backup"
  bucket        = "${module.s3_etcd_backup_bucket.value}"
  acl           = "private"
  force_destroy = true
  region        = "${local.s3_backup_vars["region"]}"

  tags {
    Name = "Cluster bucket for ${var.cluster_name}"
  }
}

module "s3_etcd_backup_id" {
  source   = "../defaults"
  optional = true
  values   = "${formatlist("%s.%s",local_file.s3_etcd_backup_secret.*.id,local_file.s3_etcd_backup_spec.*.id)}"
}


//
// explicit backup side car for static etcd deployment
//
data "template_file" "s3_backup_sidecar" {
  count    = "${module.s3_etcd_backup.if_active}"
  template = "${file("${path.module}/templates/etcd_backup/s3/sidecar.yaml")}"
  vars {
    backup_version   = "${module.versions.etcd_backup_version}"
    backup_image     = "${module.versions.etcd_backup_image}"
    service_ip       = "${var.etcd_service_ip}"
    bucket           = "${module.s3_etcd_backup_bucket.value}"
    prefix           = "${module.s3_etcd_backup_prefix.value}"
  }
}

resource "local_file" "s3_etcd_backup_sidecar" {
  count    = "${module.selfhosted_etcd.if_not_active * module.s3_etcd_backup.if_active}"
  content  = "${data.template_file.s3_backup_sidecar.rendered}"
  filename = "${module.distinct_manifests.value}/kube-etcd-backup-sidecar.yaml"
}
