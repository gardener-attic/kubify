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


data "template_file" "osrc" {
  template = "${file("${path.module}/templates/osrc")}"

  vars {
    os_auth_url = "${module.os.auth_url}"
    os_username = "${module.os.user_name}"
    os_password = "${module.os.password}"
    os_tenant_key = "${module.os.tenant_key}"
    os_tenant_value = "${module.os.tenant_value}"
    os_domain_key = "${module.os.domain_key}"
    os_domain_value = "${module.os.domain_value}"
    os_user_domain_key = "${module.os.user_domain_key}"
    os_user_domain_value = "${module.os.user_domain_value}"
    os_region = "${module.os.region}"
  }
}

resource "local_file" "osrc" {
  content = "${data.template_file.osrc.rendered}"
  filename = "${var.gen_dir}/osrc"
}

