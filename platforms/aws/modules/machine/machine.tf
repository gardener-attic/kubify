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

module "aws" {
  source = "../config"
  iaas_config = "${var.iaas_config}"
}

locals {
  cloud_init = "${lookup(var.vm_info,"cloud_init")}"
  flavor = "${lookup(var.vm_info,"flavor")}"
  keypair = "${lookup(var.vm_info,"keypair")}"
  image = "${lookup(var.vm_info,"image")}"
  subnetid = "${lookup(var.vm_info,"subnetid")}"
  secgrp = "${lookup(var.vm_info,"security_group")}"
  iam_profile = "${lookup(var.vm_info,"iam_profile")}"
  root_volume_size = "${lookup(var.vm_info,"root_volume_size")}"
  tags = "${lookup(var.vm_info,"tags")}"
}

data "template_file" "secret" {
  template = "${file("${path.module}/templates/secret.yaml")}"

  vars {
    namespace = "${var.namespace}"
    cloud_init_b64 = "${base64encode(local.cloud_init)}"
    access_key_b64 = "${base64encode(module.aws.access_key)}"
    secret_key_b64 = "${base64encode(module.aws.secret_key)}"
  }
}

data "template_file" "class" {
  template = "${file("${path.module}/templates/class.yaml")}"

  vars {
    namespace = "${var.namespace}"
    flavor = "${local.flavor}"
    keypair = "${local.keypair}"
    image = "${local.image}"
    subnetid = "${local.subnetid}"
    secgrp = "${local.secgrp}"
    region = "${module.aws.region}"
    iam_profile = "${local.iam_profile}"
    tags = "${local.tags}"
    root_volume_size = "${local.root_volume_size}"
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

