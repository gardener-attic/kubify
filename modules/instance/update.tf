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

module "update_kubelet" {
  source = "../flag"
  option = "${var.update_kubelet}"
}

resource "null_resource" "update_kubelet" {
  count = "${module.update_kubelet.flag * ( module.master_config.count + module.worker_config.count )}"

  triggers {
    content = "${md5(module.seed.kubelet_env)}"
    node = "${element(concat(module.master.ids, module.worker.ids), count.index)}"
  }
  connection {
    host = "${element(concat(module.master.ips, module.worker.ips), count.index)}"
    type     = "ssh"
    user     = "core"
    private_key = "${module.iaas.private_key}"

    bastion_host = "${module.bastion_host.value}"
    bastion_user = "${module.bastion_user.value}"
    bastion_private_key = "${module.iaas.private_key}"
  }

  provisioner "file" {
    content = "${module.seed.kubelet_env}"
    destination = "kubelet.env"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp kubelet.env /etc/kubernetes/_kubelet.env",
      "sudo mv /etc/kubernetes/_kubelet.env /etc/kubernetes/kubelet.env",
      "sudo mv kubelet.env /var/kubernetes/kubelet.env",
    ]
  }
}

output "workercount" {
  value = "${module.worker_config.count}"
}

output "mastercount" {
  value = "${module.master_config.count}"
}