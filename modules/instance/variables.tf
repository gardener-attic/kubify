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

###############################################################
# typical variables to set for all cluster projects
###############################################################


variable "ca_cert_pem" {
  default = ""
}
variable "ca_key_pem" {
  default = ""
}

variable "cluster_name" {
  type = "string"
}
variable "cluster_type" {
  type = "string"
}

variable "bastion" {
  type = "map"
  default = { }
}

variable "cluster-lb" {
  type = "string"
  default = "false"
}

#
# node config for worker and master
#
variable "worker" {
  type = "map"
  default = { }
}
variable "master" {
  type = "map"
  default = { }
}

variable "worker_count" {
  default = 1
}
variable "assign_worker_fips" {
  default = false
}
variable "worker_update_mode" {
  default = ""
}
variable "worker_generation" {
  default = 0
}
variable "worker_image_name" {
  type = "string"
  default = ""
}
variable "worker_flavor_name" {
  type = "string"
  default = ""
}

# deprecated
variable "master_count" {
  default = 1
}
variable "assign_master_fips" {
  default =  false
}
variable "master_update_mode" {
  default = ""
}
variable "master_generation" {
  default = 0
}
variable "master_image_name" {
  type = "string"
  default = ""
}
variable "master_flavor_name" {
  type = "string"
  default = ""
}

variable "master_volume_size" {
  type = "string"
  default = "20"
}
############

variable "etcd_backup_file" {
  type = "string"
  default = ""
}
variable "recover_cluster" {
  default = false
}
variable "keep_recovery_version" {
  default = "false"
}
variable "provision_bootkube" {
  default = false
}
variable "root_certs_file" {
  type = "string"
  default = ""
}
variable "pull_secret_file" {
  type = "string"
  default = ""
}

variable "dashboard_user" {
  default = ""
}
variable "dashboard_password" {
  default = ""
}
variable "dashboard_creds" {
  default = "admin:$apr1$BgPuasJn$W7sw.khdm/VqoZirMe6uE1"
}

variable "base_domain" {
  type = "string"
  default = ""
}
variable "domain_name" {
  type = "string"
  default = ""
}
variable "additional_domains" {
  type = "list"
  default = []
}

variable "dns_nameservers" {
  type = "list"
  default = [
  ]
}

variable "flavor_name" {
  default = ""
}

variable "bastion_image_name" {
  default = "ubuntu-16.04"
}
variable "bastion_user" {
  default = "ubuntu"
}

variable "bastion_flavor_name" {
  default = ""
}


#
# oidc parameters for api server
#
variable "oidc_issuer_domain" {
  default = ""
}
variable "oidc_issuer_subdomain" {
  default = ""
}
variable "oidc_client_id" {
  default = "kube-kubectl"
}
variable "oidc_username_claim" {
  default = "email"
}
variable "oidc_groups_claim" {
  default = "groups"
}

#
# flags
#

variable "use_bastion" {
  default = true
}

variable "use_lbaas" {
  default = true
}
variable "configure_additional_dns" {
  default = false
}



#
# vm update modes
#
variable "node_update_mode" {
  default = "Roll"
}
variable "generation" {
  default = 0
}

variable "update_kubelet" {
  default = false
}

# ooppps
# set this to true, to delete only the lbaas iaas elements
variable "omit_lbaas" {
  default = false
}

variable "addons" {
  default = {
    "dashboard" = { }
    "nginx-ingress" = { }
    "heapster" = { }
  }
}


###############################################################
# constants
###############################################################

#
# iaas
#
variable "subnet_cidr" {
  type = "string"
  default = ""
}
variable "service_cidr" {
  type = "string"
  default = "10.241.0.0/17"
}
variable "pod_cidr" {
  type = "string"
  default = "10.241.128.0/17"
}


variable "host_ssl_certs_dir" {
  default = "/etc/ssl/certs"
}

variable "api_ports" {
  default = [ "443" ]
}

variable "nginx_ports" {
  default = [ "80", "443" ]
}

###############################################################
# process related inputs
###############################################################

variable "bootkube" {
  default = 1
}

variable "master_state" {
  default = { }
}
variable "worker_state" {
  default = { }
}
variable "recovery_version" {
  default = "0"
}
