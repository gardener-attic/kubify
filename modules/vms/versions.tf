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
  image_versions = {
    "openstack" = {
      "ubuntu-16.04" = "ubuntu-16.04"
      "coreos-1745.7.0" = "coreos-1745.7.0"
    }
    "aws" = {
      "ubuntu-16.04" = "ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server"
      "coreos-1745.7.0" = "CoreOS-stable-1745.7.0-hvm"
    }
    "azure" = {
      "ubuntu-16.04" = "Canonical/UbuntuServer/16.04-LTS/latest"
      "azure-latest" = "CoreOS/CoreOS/Beta/latest"
      "coreos-1745.7.0" = "CoreOS/CoreOS/Stable/1745.7.0"
    }
  }

  flavor_names = {
    "openstack" = {
      default = "medium_2_4"
    }
    "aws" = {
      default = "m4.large"
      bastion = "t2.medium"
    }
    "azure" = {
      default = "Standard_DS2_v2"
      bastion = "Standard_A2"
    }
  }
}

