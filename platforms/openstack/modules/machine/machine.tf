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

locals {
  mapping = {
    OS_PROJECT_DOMAIN_NAME = "domainName"
    OS_PROJECT_DOMAIN_ID = "domainId"
    OS_TENANT_NAME = "tenantName"
    OS_TENANT_ID = "tenantId"
  }
}
module "os" {
  source = "../config"
  iaas_config = "${var.iaas_config}"
}

locals {
  cloud_init = "${lookup(var.vm_info,"cloud_init")}"
  flavor = "${lookup(var.vm_info,"flavor")}"
  keypair = "${lookup(var.vm_info,"keypair")}"
  image = "${lookup(var.vm_info,"image")}"
  networkid = "${lookup(var.vm_info,"networkid")}"
  secgrp = "${lookup(var.vm_info,"security_group")}"
  tags = "${lookup(var.vm_info,"tags")}"
}

data "template_file" "secret" {
  template = "${file("${path.module}/templates/secret.yaml")}"

  vars {
    namespace        = "${var.namespace}"
    cloud_init_b64   = "${base64encode(local.cloud_init)}"
    auth_url_b64     = "${base64encode(module.os.auth_url)}"
    username_b64     = "${base64encode(module.os.user_name)}"
    password_b64     = "${base64encode(module.os.password)}"
    domain_key       = "${local.mapping[module.os.domain_key]}"
    domain_value_b64 = "${base64encode(module.os.domain_value)}"
    tenant_key       = "${local.mapping[module.os.tenant_key]}"
    tenant_value_b64 = "${base64encode(module.os.tenant_value)}"
    cacert_b64       = "${base64encode(module.os.cacert)}"
    insecure_b64     = "${base64encode(module.os.insecure)}"
  }
}

data "template_file" "class" {
  template = "${file("${path.module}/templates/class.yaml")}"

  vars {
    namespace = "${var.namespace}"
    flavor = "${local.flavor}"
    keypair = "${local.keypair}"
    image = "${local.image}"
    networkid = "${local.networkid}"
    secgrp = "${local.secgrp}"
    region = "${module.os.region}"
    az     = "${module.os.availability_zone}"
    tags = "${local.tags}"
  }
}

data "template_file" "deployment" {
  template = "${file("${path.module}/templates/deployment.yaml")}"

  vars {
    namespace = "${var.namespace}"
    worker_count = "${var.count}"
  }
}

output "manifests" {
  value = <<EOF
---
${data.template_file.secret.rendered}
---
${data.template_file.class.rendered}
---
${data.template_file.deployment.rendered}
EOF
}

