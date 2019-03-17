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

variable "test" {
  default = 0
}


module "provision" {
  source = "./../flag"
  option= "${var.provision_bootkube}"
}
module "provision_helper" {
  source = "./../flag"
  option= "${var.provision_helper}"
}
module "setup_etcd" {
  source = "./../flag"
  option= "${var.setup_etcd}"
}
module "omit_bootkube" {
  source = "./../flag"
  option= "${var.omit_bootkube}"
}
module "bootkube" {
  source = "./../flag"
  option= "${var.bootkube}"
}

resource "null_resource" "etcd_provision" {
  count = "${module.master_config.count * module.selfhosted_etcd.if_not_active}"
  triggers {
    sha = "${module.seed.etcdtls_sha}"
    master = "${module.master.ids[count.index]}"
    manifest = "${module.seed.etcd_manifests[count.index]}"
  }

  connection {
    host = "${module.master.ips[count.index]}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "file" {
    content = "${file(module.seed.etcdtls_path)}"
    destination = "etcdtls.zip"
  }
  provisioner "file" {
    content = "${module.seed.etcd_manifests[count.index]}"
    destination = "kube-etcd.yaml"
  }
}
output "etcd_provision" {
  value = {
    master = "${module.master_config.count}"
    selfhosted = "${module.selfhosted_etcd.if_not_active}"
    active = "${signum(module.bootkube.if_active + module.recover_cluster.if_active + module.provision.if_active)}"
    count = "${module.master_config.count * module.selfhosted_etcd.if_not_active * signum(module.bootkube.if_active + module.recover_cluster.if_active + module.provision.if_active)}"
  }
}

resource "null_resource" "etcd_setup" {
  depends_on = [ "null_resource.etcd_provision" ]
  #count = "${module.master_config.count * module.selfhosted_etcd.if_not_active * signum(module.bootkube.if_active + module.recover_cluster.if_active) * module.setup_etcd.if_active}"
  count = "${module.master_config.count * module.selfhosted_etcd.if_not_active * module.setup_etcd.if_active}"

  triggers {
    provision = "${element(null_resource.etcd_provision.*.id,count.index)}"
    version = "1"
  }

  connection {
    host = "${module.master.ips[count.index]}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "rm -rf etcdtls && unzip etcdtls.zip -d etcdtls",
      "sudo mkdir -p /etc/kubernetes/static-secrets",
      "sudo rm -rf /etc/kubernetes/static-secrets/etcd",
      "sudo mv etcdtls/* /etc/kubernetes/static-secrets",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/kubernetes/manifests",
      "sudo cp kube-etcd.yaml /etc/kubernetes/manifests",
    ]
  }
}

resource "null_resource" "helper_provision" {
  count = "${module.master_config.count}"
  triggers {
    recover = "${module.recovery_version.value}"
    sha = "${module.seed.bootkube_sha}"
    bootkube = "${module.bootkube_image.value}"
    master = "${element(module.master.ids,count.index)}"
    archive_sha = "${data.archive_file.helper_scripts.output_sha}"
  }

  connection {
    host = "${module.master.ips[count.index]}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "file" {
    content = "${file(data.archive_file.helper_scripts.output_path)}"
    destination = "helper.zip"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${module.cluster.bootkube_inst_dir}/bin",
      "sudo unzip -o helper.zip -d ${module.cluster.bootkube_inst_dir}/bin/",
      "sudo chmod +x ${module.cluster.bootkube_inst_dir}/bin/*"
    ]
  }
}

resource "null_resource" "master_provision" {
  depends_on = [ "null_resource.helper_provision" ]
  triggers {
    recover = "${module.recovery_version.value}"
    sha = "${module.seed.bootkube_sha}"
    bootkube = "${module.bootkube_image.value}"
    master = "${element(module.master.ids,0)}"
  }

  connection {
    host = "${module.master.ips[0]}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "file" {
    content = "${file(module.seed.bootkube_path)}"
    destination = "bootkube.zip"
  }
}

resource "null_resource" "master_setup" {
  depends_on = [ "null_resource.master_provision" ]

  triggers {
    provision = "${null_resource.master_provision.id}"
  }

  connection {
    host = "${module.master.ips[0]}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p ${module.cluster.bootkube_inst_dir}/bin",
      "rm -rf bootkube && unzip bootkube.zip -d bootkube",
      "sudo rm -rf ${module.cluster.assets_inst_dir}",
      "sudo mv bootkube ${module.cluster.assets_inst_dir}",
    ]
  }
}

resource "null_resource" "master_controlplane_recover" {
  depends_on = [ "null_resource.master_setup" ]
  count = "${module.omit_bootkube.if_not_active * module.bootkube.if_not_active * module.recover_cluster.if_not_active}"

  triggers {
    host = "${module.master.ips[0]}"
  }

  connection {
    host = "${module.master.ips[0]}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "${module.cluster.bootkube_inst_dir}/bin/recover-controlplane.sh",
    ]
  }
}

resource "local_file" "reset_bootkube" {
  depends_on = [ "null_resource.master_setup" ]
  content     = "bootkube=0"
  filename = "${path.cwd}/bootkube.auto.tfvars"
}

resource "local_file" "access_info" {
  content     = <<EOF
master = "${element(module.master.ids,0)}"
master_ip = "${element(module.master.ips,0)}"
bastion_ip = "${module.bastion_host.value}"
bastion_user = "${module.bastion_user.value}"
EOF
  filename = "${module.cluster.gen_dir}/access_info"
}

resource "null_resource" "test" {
  count = "${var.test}"
  triggers {
    master = "${element(module.master.ids,0)}"
    master_ip = "${element(module.master.ips,0)}"
    bastion_ip = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    test   = 2
  }

  connection {
    host = "${module.master.ips[0]}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "file" {
    content = "demo"
    destination = "demo"
  }
}

output "etcd_backup_file" {
  value = "${var.etcd_backup_file}"
}
