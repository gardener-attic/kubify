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

module "azure" {
  source = "../config"
  iaas_config = "${var.iaas_config}"
}

locals {
  cloud_init = "${lookup(var.vm_info,"cloud_init")}"
  flavor = "${lookup(var.vm_info,"flavor")}"
  image = "${lookup(var.vm_info,"image")}"
  subnet = "${lookup(var.vm_info,"subnet_name")}"
  vnet = "${lookup(var.vm_info,"vnet","")}"
  resource_group = "${lookup(var.vm_info,"resource_group")}"
  availability_set = "${lookup(var.vm_info,"availability_set")}"

  admin_user = "${lookup(var.vm_info,"admin_user")}"
  root_volume_size = "${lookup(var.vm_info,"root_volume_size")}"

  tags = "${lookup(var.vm_info,"tags")}"

  separator = "/"

  publisher = "${element(split("${local.separator}",local.image),0)}"
  offer = "${element(split("${local.separator}",local.image),1)}"
  sku = "${element(split("${local.separator}",local.image),2)}"
  version = "${element(split("${local.separator}",local.image),3)}"
}

data "template_file" "secret" {
  template = "${file("${path.module}/templates/secret.yaml")}"

  vars {
    namespace = "${var.namespace}"
    cloud_init_b64 = "${base64encode(local.cloud_init)}"
    client_id_b64 = "${base64encode(module.azure.client_id)}"
    client_secret_b64 = "${base64encode(module.azure.client_secret)}"
    subscription_id_b64 = "${base64encode(module.azure.subscription_id)}"
    tenant_id_b64 = "${base64encode(module.azure.tenant_id)}"
  }
}

data "template_file" "class" {
  template = "${file("${path.module}/templates/class.yaml")}"

  vars {
    namespace = "${var.namespace}"

    flavor = "${local.flavor}"
    subnet = "${local.subnet}"
    location = "${module.azure.region}"
    resource_group = "${local.resource_group}"
    availability_set = "${local.availability_set}"
    vnet = "${local.vnet}"
    tags = "${local.tags}"

    publisher = "${local.publisher}"
    offer = "${local.offer}"
    sku = "${local.sku}"
    version = "${local.version}"
    public_key = ""
    admin_user = "${local.admin_user}"
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

