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



module "recover" {
  source = "../configurable"
  optional = true
  value = "${var.etcd_backup_file}"
}

module "backup_dir" {
  source = "../variable"
  value = "${var.assets_inst_dir}/etcd"
}

locals {
  backup_file = "etcd.backup"

  cmd = "mkdir -p \"${var.gen_dir}/assets/etcd\" && cp \"${var.etcd_backup_file}\" \"${var.gen_dir}/assets/etcd/${local.backup_file}\"" 
  copy = "${module.recover.if_configured ? "${local.cmd}" : "echo no backup" }"
}

resource "null_resource" "etcd_backup" {
  triggers {
    recover = "${var.vm_version}"
  }

  provisioner "local-exec" {
    command  = "${local.copy}"
  }
}

#
# prepare manifest fragments for bootstrap etcd
#

locals {
  etcd_mount="${file("${path.module}/templates/etcd_bootstrap/recover_mount_etcd")}"
  etcd_backup_mount="${file("${path.module}/templates/etcd_bootstrap/recover_mount_backup")}"
}

module "etcd_mount" {
  source = "../variable"
  value = "${module.recover.if_configured ? local.etcd_mount : ""}"
}

data "template_file" "etcd_recover_volumes" {
  template = "${file("${path.module}/templates/etcd_bootstrap/recover_volumes")}"
  vars {
    etcd_backup_dir="${module.backup_dir.value}"
  }
}
module "etcd_volumes" {
  source = "../variable"
  value = "${module.recover.if_configured ? data.template_file.etcd_recover_volumes.rendered : ""}"
}



data "template_file" "etcd_recover_initcontainers" {
  count = "${module.selfhosted_etcd.if_active}"
  template = "${file("${path.module}/templates/etcd_bootstrap/recover_initcontainers")}"
  vars {
    etcd_version = "${module.versions.etcd_version}"
    crd_key= "/registry/etcd.database.coreos.com/etcdclusters/kube-system/kube-etcd"
    member_pod_prefix = "/registry/pods/kube-system/kube-etcd-"

    bootstrap_etcd_service_ip = "${var.bootstrap_etcd_service_ip}"
    etcd_mount = "${local.etcd_mount}"
    etcd_backup_mount = "${local.etcd_backup_mount}"
    backup_file="${local.backup_file}"
  }
}
data "template_file" "static_etcd_recover_initcontainers" {
  count = "${module.selfhosted_etcd.if_not_active}"
  template = "${file("${path.module}/templates/etcd_bootstrap/static_recover_initcontainers")}"
  vars {
    name = "${var.etcd_names[0]}"
    service_name = "${var.etcd_service_name}"
    domain = "${var.etcd_domains[0]}"
    initial_cluster = "${local.etcd_members[0]}"
    version = "${module.versions.etcd_version}"

    etcd_mount = "${local.etcd_mount}"
    etcd_backup_mount = "${local.etcd_backup_mount}"
    backup_file="${local.backup_file}"
  }
}
module "etcd_initcontainers" {
  source = "../variable"
  value = "${module.recover.if_configured ? element(concat(data.template_file.etcd_recover_initcontainers.*.rendered,data.template_file.static_etcd_recover_initcontainers.*.rendered),0) : ""}"
}


data "template_file" "etcd_initial" {
  template = "${file("${path.module}/templates/etcd_bootstrap/initial")}"
  vars {
    bootstrap_etcd_service_ip = "${var.bootstrap_etcd_service_ip}"
  }
}
module "etcd_initial" {
  source = "../variable"
  value = "${module.recover.if_not_configured ? data.template_file.etcd_initial.rendered : ""}"
}
