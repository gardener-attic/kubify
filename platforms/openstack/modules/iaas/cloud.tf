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


locals {
  mapping = {
    OS_PROJECT_DOMAIN_NAME = "domain-name"
    OS_PROJECT_DOMAIN_ID = "domain-id"
    OS_TENANT_NAME = "tenant-name"
    OS_TENANT_ID = "tenant-id"
  }
}

data "template_file" "cloud_conf" {
  template = "${file("${path.module}/templates/cloud.conf")}"

  vars {
    os_auth_url = "${module.os.auth_url}"
    os_username = "${module.os.user_name}"
    os_password = "${module.os.password}"
    os_tenant_key = "${local.mapping[module.os.tenant_key]}"
    os_domain_key = "${local.mapping[module.os.domain_key]}"
    os_tenant_value = "${module.os.tenant_value}"
    os_domain_value = "${module.os.domain_value}"
    fip_subnet_id = "${data.openstack_networking_network_v2.fip.id}"
    lb_subnet_id = "${openstack_networking_subnet_v2.cluster.id}"
    lb_provider = "${module.os.lbaas_provider}"
  }
}

resource "local_file" "cloud_conf" {
  content = "${data.template_file.cloud_conf.rendered}"
  filename = "${var.gen_dir}/iaas/cloud.conf"
}


output "cloud_conf" {
  value = "${data.template_file.cloud_conf.rendered}"
}

