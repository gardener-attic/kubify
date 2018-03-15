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


variable "iaas_config" {
  type = "map"
}
variable "cloud_provider" {
}
variable "file" {
  type = "map"
  default = {}
}

variable "cluster_name" {
  type = "string"
}
variable "cluster_type" {
  type = "string"
}
variable "node_type" {
  type = "string"
}
variable "kubernetes_version" {
  type = "string"
}
variable "kubernetes_hyperkube" {
  type = "string"
}
variable "kubernetes_hyperkube_patch" {
  type = "string"
}
variable "gen_dir" {
  type = "string"
}
variable "prefix" {
  type = "string"
}
variable "node_count" {
  type = "string"
}
variable "image_name" {
  type = "string"
}
variable "flavor_name" {
  type = "string"
}
variable "security_group" {
  type = "string"
}
variable "iaas_info" {
  type = "map"
}
variable "volume_size" {
  type = "string"
  default = "20"
}
variable "root_volume_size" {
  type = "string"
  default = "50"
}

variable "tags" {
  type = "map"
  default = { }
}
variable "kubeconfig" {
  type = "string"
}
variable "cloud_conf" {
  type = "string"
}
variable "cloud_init" {
  type = "map"
  default = { }
}
variable "dns_service_ip" {
  type = "string"
}
variable "root_certs" {
  type = "string"
}
variable "admin_user" {
  default = "core"
}
variable "key" {
  type = "string"
}
variable "provide_fips" {
  default = "false"
}
variable "provide_storage" {
  default = false
}
variable "assets_inst_dir" {
  default = ""
}
variable "bootkube_inst_dir" {
  default = ""
}
variable "bootkube_image" {
  default = ""
}
variable "setup_volume_script" {
  default = ""
}
variable "generation" {
  default = "1"
}
variable "vm_version" {
  default = "0"
}

variable "node_labels" {
  type = "list"
  default = []
}
variable "node_taints" {
  type = "list"
  default = []
}

variable "kube_mount_path" {
  default = "/etc/kubernetes"
}
variable "etcd_mount_path" {
  default = "/var/etcd"
}
variable "device" {
  default = "/dev/vdb"
}


variable "state" {
  type = "map"
  default = { }
}
variable "update_mode" {
  type = "string"
  default = "Roll"   # values are Roll, All or None
}


variable "provide_lbaas" {
  default = false
}
variable "lbaas_ports" {
  type = "list"
  default = [ ]
}
variable "subnet_id" {
  type = "string"
  default = ""
}
variable "lbaas_name" {
  type = "string"
  default = ""
}
variable "lbaas_description" {
  type = "string"
  default = ""
}

##########################################
# evaluate switches
#

module "storage" {
  source = "../variable"
  value = "${var.provide_storage ? 1 : 0}"
}

module "zip" {
  source = "../variable"
  value = "${module.vms.short_user_data ? 1 : 0}"
}

##########################################
# prepare cloud init flavors
#
module "node_labels" {
  source = "../variable"
  value = "${length(var.node_labels)==0 ? "" : "        --node-labels=${join(",",var.node_labels)} \\\n"}"
}  
module "node_taints" {
  source = "../variable"
  value = "${length(var.node_taints)==0 ? "" : "        --register-with-taints=${join(",",var.node_taints)} \\\n"}"
}  

#
# volume
#
variable "argsep" {
  default = "\" \""
}

data "template_file" "volume_service" {
  template = "${file("${path.module}/templates/volume.service")}"
  
  vars {
    device = "${var.device}"
    path = "${join(var.argsep, list(var.etcd_mount_path, var.kube_mount_path))}"
  }
}
module "volume_service" {
  source = "../variable"
  value = "${module.storage.value ? data.template_file.volume_service.rendered : ""}"
}


module "etcd_mount" {
  source = "mount_point"

  use = "${module.storage.value}"
  device = "${var.device}2"
  path = "${var.etcd_mount_path}"
}
module "kube_mount" {
  source = "mount_point"

  use = "${module.storage.value}"
  device = "${var.device}1"
  path = "${var.kube_mount_path}"
}


#
# bootkube service
#
data "template_file" "bootkube" {
  template = "${file("${path.module}/templates/bootkube.service")}"
  
  vars {
    bootkube_done_dir = "${var.kube_mount_path}"
    bootkube_image = "${var.bootkube_image}"
    bootkube_inst_dir = "${var.bootkube_inst_dir}"
    assets_inst_dir = "${var.assets_inst_dir}"
  }
}

module "updatecacerts" {
  source = "../flag"
  option = "true"
}

module "updatecacerts_service" {
  source = "../variable"
  value = "${module.updatecacerts.if_active ? file("${path.module}/resources/updatecacerts.service") : ""}"
}

module "bootkube_service" {
  source = "../variable"
  value = "${var.node_type == "master" ? data.template_file.bootkube.rendered : ""}"
}

module "services" {
  source = "../variable"
  value = "${module.bootkube_service.value}"
}
module "mount_points" {
  source = "../variable"
  value = "${module.etcd_mount.entry}"
}

module "units" {
  source = "../variable"
  value = "${module.volume_service.value}${module.etcd_mount.entry}${module.kube_mount.entry}${module.bootkube_service.value}${module.updatecacerts_service.value}"
}

#
# additional path entries
#
module "setup_volume" {
  source = "path_entry"
  path =  "/opt/bin/setup_volume"
  permissions =  "0755"
  content = "${file("${path.module}/resources/setup_volume")}"
}
module "cert_file" {
  source = "path_entry"
  path =  "/etc/ssl/certs/ROOTcerts.pem"
  permissions =  "0644"
  content = "${var.root_certs}"
  omit_empty = true
}
module "info_file" {
  source = "path_entry"
  path =  "${lookup(var.file,"path","")}"
  permissions =  "${lookup(var.file,"permissions","0644")}"
  content =  "${lookup(var.file,"content","")}"
  omit_empty = true
}

module "paths" {
  source = "../variable"
  value = "${module.storage.value ? module.setup_volume.entry : ""}${module.cert_file.entry}${module.info_file.entry}"
}

module "bootstrap_steps" {
  source = "../variable"
  value = "${module.storage.value ? "      ExecStartPre=/bin/sh /opt/bin/setup_volume \"${var.device}\" \"${var.etcd_mount_path}\" \"${var.kube_mount_path}\"\n" : ""}"
}

##########################################
# cloud init
#

data "template_file" "cloud_init" {
  template = "${file("${path.module}/templates/cloud-init")}"

  vars {
    cloud_provider = "${var.cloud_provider}"
    cluster_dns = "${var.dns_service_ip}"
    kubelet_version = "${var.kubernetes_version}${var.kubernetes_hyperkube_patch}"
    kubelet_image_tag = "${var.kubernetes_version}${var.kubernetes_hyperkube_patch}"
    kubelet_image = "${var.kubernetes_hyperkube}"
    cloud_conf_b64 = "${base64encode(var.cloud_conf)}"
    kubelet_conf_b64 = "${base64encode(var.kubeconfig)}"
    setup_kubeenv_script_b64 = "${base64encode(file("${path.module}/resources/setup_kubeenv"))}"
    generation = "${var.generation}"
  
    #
    # flavored properties
    kubelet_args = "${module.node_labels.value}${module.node_taints.value}"
    units = "${module.units.value}${lookup(var.cloud_init,"units","")}"
    paths = "${module.paths.value}${lookup(var.cloud_init,"write_files","")}"
    kubelet_deps = "${module.updatecacerts.if_active ? " updatecacerts.service" : ""}"

#    bootstrap_steps = "${module.bootstrap_steps.value}"
#    services = "${module.services.value}"
#    mount_points    = "${module.mount_points.value}"
  }
}

resource "local_file" "cloud_init" {
  content = "${data.template_file.cloud_init.rendered}"
  filename = "${var.gen_dir}/${var.node_type}.cloud-init"
}

data "template_file" "cloud_init_wrapper" {
  template = "${file("${path.module}/templates/cloud-init-wrapper")}"

  vars {
    cloud_init_gzb64 = "${base64gzip(data.template_file.cloud_init.rendered)}"
  }
}

resource "local_file" "cloud_init_wrapper" {
  content = "${data.template_file.cloud_init_wrapper.rendered}"
  filename = "${var.gen_dir}/${var.node_type}.cloud-init-wrapper"
}

resource "local_file" "cloud_init_zip" {
  count = 0
  content = "${base64decode(base64gzip(data.template_file.cloud_init.rendered))}"
  filename = "${var.gen_dir}/${var.node_type}.cloud-init.gz"
}

module "cloud_init" {
  source = "../variable"
  value = "${module.zip.value ? data.template_file.cloud_init_wrapper.rendered : data.template_file.cloud_init.rendered}"
}

module "vms" {
  source = "../../variants/current/modules/vms"

  vm_version        = "${var.vm_version}"
  iaas_config       = "${var.iaas_config}" 
  state             = "${var.state}"
  update_mode       = "${var.update_mode}"

  prefix            = "${var.prefix}"

  cluster_name      = "${var.cluster_name}"
  cluster_type      = "${var.cluster_type}"
  node_type         = "${var.node_type}"
  node_count        = "${var.node_count}"

  image_name        = "${var.image_name}"
  flavor_name       = "${var.flavor_name}"

  tags              = "${merge(var.tags,map("KubernetesCluster","${var.cluster_name}", "kubernetes.io/cluster/${var.cluster_name}", "1"))}"
  admin_user        = "${var.admin_user}"
  key               = "${var.key}"

  security_group    = "${var.security_group}"
  iaas_info         = "${var.iaas_info}"

  root_volume_size  = "${var.root_volume_size}"
  volume_size       = "${var.volume_size}"
  provide_storage   = "${var.provide_storage}"
  provide_fips      = "${var.provide_fips}"

  cloud_init        = "${module.cloud_init.value}"


  provide_lbaas = "${var.provide_lbaas}"
  lbaas_ports = "${var.lbaas_ports}"
  lbaas_name = "${var.lbaas_name}"
  lbaas_description = "${var.lbaas_description}"
  subnet_id = "${var.subnet_id}"
}

output "vm_version" {
  value = "${var.vm_version}"
}
output "ids" {
  value = "${module.vms.ids}"
}
output "ips" {
  value = "${module.vms.ips}"
}
output "fips" {
  value = "${module.vms.fips}"
}

output "state" {
  value ="${module.vms.state}"
}
output "info" {
  value = "${module.vms.info}"
}


output "lbaas_address" {
  value = "${module.vms.lbaas_address}"
}
output "lbaas_address_type" {
  value = "${module.vms.lbaas_address_type}"
}

output "generation" {
  value = "${var.generation}"
}

output "vm_info" {
 value = "${module.vms.vm_info}"
}

