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


module "recover_cluster" {
  source = "./modules/flag"
  option= "${var.recover_cluster && length(var.etcd_backup_file)>0}"
}
module "keep_version" {
  source = "./modules/flag"
  option= "${var.keep_recovery_version}"
}



# This is used to enforce master recreation for recoveries
# Whenever a recovery is requested the recovery version is increased
# to enforce new master nodes
module "recovery_version" {
  source = "./modules/variable"
  value = "${module.recover_cluster.if_active && module.keep_version.if_not_active ? var.recovery_version + 1 : var.recovery_version}"
}

output "vm_version" {
  value = "${module.recovery_version.value}"
}

#
# only required for recovery with already existing master VMs
# but so far we always recreate the VMs
#
resource "null_resource" "trigger_recover" {
  count = "${module.recover_cluster.if_active}"

  triggers {
    uuid = "${module.recovery_version.value}"
  }


  connection {
    host = "${element(module.master.ips, 0)}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rm -Rf ${module.cluster.assets_inst_dir}",
      "sudo rm -f /etc/kubernetes/init_bootkube.done",
      "sudo rm -Rf /etc/kubernetes/bootstrap-secrets /etc/kubernetes/manifests/*",
      "sudo systemctl restart bootkube.path"
    ]
  }
}

