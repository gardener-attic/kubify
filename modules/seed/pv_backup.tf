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


module "pv_etcd_backup" {
  source = "../flag"
  option = "${module.etcd_backup.value == "pv"}"
}

data "template_file" "pv_etcd_backup_spec" {
  count = "${module.pv_etcd_backup.flag}"
  template = "${file("${path.module}/templates/etcd_backup/pv/spec.json")}"
  vars {
  }
}

resource "local_file" "pv_etcd_backup_spec" {
  count = "${module.pv_etcd_backup.flag}"
  content  = "{ \"spec\": { \n${data.template_file.pv_etcd_backup_spec.rendered}}}"
  filename = "${module.etcd_backup_spec.value}"
}


module "pv_etcd_backup_id" {
  source = "../defaults"
  optional  = true
  values = "${formatlist("%s",local_file.pv_etcd_backup_spec.*.id)}"
}
