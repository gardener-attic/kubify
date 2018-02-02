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

module "availability_zone" {
  source = "../../../../modules/variable"
  value = "${module.aws.region}${module.aws.availability_zone}"
}

module "suffix" {
  source = "../../../../modules/variable"
  value = "${var.dns_domain}"
  default = "${var.prefix}"
}

resource "aws_vpc" "cluster" {
  cidr_block = "${module.aws.vpc_cidr}"
  tags {
    Name = "${var.prefix}"
  }
}

module "public_cidr" {
  source = "../../../../modules/variable"
  value = "${module.aws.public_subnet_cidr}"
  default = "${cidrsubnet(module.aws.vpc_cidr,2,0)}"
}
module "private_cidr" {
  source = "../../../../modules/variable"
  value = "${module.aws.public_subnet_cidr}"
  default = "${cidrsubnet(module.aws.vpc_cidr,2,1)}"
}
module "nodes_cidr" {
  source = "../../../../modules/variable"
  value = "${var.subnet_cidr}"
  default = "${cidrsubnet(module.aws.vpc_cidr,1,1)}"
}

#
# public internet access
#
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.cluster.id}"
  tags {
    Name = "${var.prefix}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.cluster.id}"

  tags {
    Name = "${var.prefix}-public"
  }
}

resource "aws_route" "public" {
  route_table_id = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.igw.id}"
}


# public util subnet
resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.cluster.id}"
  cidr_block = "${module.public_cidr.value}"
  availability_zone = "${module.availability_zone.value}"

  tags {
    Name = "${var.prefix}-public"
    Cluster = "${var.cluster_name}"
  }
}
resource "aws_route_table_association" "public" {
   subnet_id = "${aws_subnet.public.id}"
   route_table_id = "${aws_route_table.public.id}"
}

#
# natted internet access
#

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id = "${aws_subnet.public.id}"

  tags {
    Name = "${var.prefix}"
  }
}

resource "aws_route_table" "nat" {
  vpc_id = "${aws_vpc.cluster.id}"

  tags {
    Name = "${var.prefix}"
  }
}
resource "aws_route" "nat" {
  route_table_id = "${aws_route_table.nat.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.ngw.id}"
}

# private util subnet
resource "aws_subnet" "private" {
  vpc_id     = "${aws_vpc.cluster.id}"
  cidr_block = "${module.private_cidr.value}"
  availability_zone = "${module.availability_zone.value}"

  tags {
    Name = "${var.prefix}-private"
    Cluster = "${var.cluster_name}"
  }
}
resource "aws_route_table_association" "private" {
  subnet_id = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.nat.id}"
}

# private nodes subnet
resource "aws_subnet" "nodes" {
  vpc_id     = "${aws_vpc.cluster.id}"
  cidr_block = "${module.nodes_cidr.value}"
  availability_zone = "${module.availability_zone.value}"

  tags {
    Name = "${var.prefix}-nodes"
    Cluster = "${var.cluster_name}"
  }
}
resource "aws_route_table_association" "nodes" {
  subnet_id = "${aws_subnet.nodes.id}"
  route_table_id = "${aws_route_table.nat.id}"
}

#
# security groups
#

resource "aws_security_group" "cluster" {
  name        = "${var.prefix}-cluster"
  description = "Common Cluster Access"
  vpc_id      = "${aws_vpc.cluster.id}"

  tags {
    Name = "${var.prefix}-cluster"
  }
}

resource "aws_security_group_rule" "cluster-self" {
  security_group_id = "${aws_security_group.cluster.id}"
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  source_security_group_id = "${aws_security_group.cluster.id}"
}
resource "aws_security_group_rule" "cluster-ssh" {
  security_group_id = "${aws_security_group.cluster.id}"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "cluster-egress" {
  security_group_id = "${aws_security_group.cluster.id}"
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}


resource "aws_security_group" "public" {
  name        = "${var.prefix}-public"
  description = "Public Access"
  vpc_id      = "${aws_vpc.cluster.id}"

  tags {
    Name = "${var.prefix}-public"
  }
}
resource "aws_security_group_rule" "public" {
  security_group_id = "${aws_security_group.public.id}"
  type = "ingress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "ssh" {
  name        = "${var.prefix}-ssh"
  description = "Public Access"
  vpc_id      = "${aws_vpc.cluster.id}"

  tags {
    Name = "${var.prefix}-public"
  }
}
resource "aws_security_group_rule" "ssh" {
  security_group_id = "${aws_security_group.ssh.id}"
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

##########################################

module "iaas_info" {
  source = "../../../../modules/mapvar"
  value = {
    availability_zone = "${module.availability_zone.value}"
    secgrp_ssh        = "${aws_security_group.ssh.id}"
    secgrp_public     = "${aws_security_group.public.id}"
    private_subnet_id = "${aws_subnet.private.id}"
    public_subnet_id  = "${aws_subnet.public.id}"
    vpc_id            = "${aws_vpc.cluster.id}"
    bastion_instance_profile = "${aws_iam_instance_profile.bastion.name}"
    master_instance_profile  = "${aws_iam_instance_profile.master.name}"
    worker_instance_profile  = "${aws_iam_instance_profile.worker.name}"
  }
}

output "iaas_info" {
  value = "${module.iaas_info.value}"
}
output "nodes_cidr" {
  value = "${module.nodes_cidr.value}"
}
output "subnet_id" {
  value = "${aws_subnet.nodes.id}"
}
output "security_group_id" {
  value = "${aws_security_group.cluster.id}"
}
output "security_group" {
  value = "${aws_security_group.cluster.id}"
}

output "default_user" {
  value = "k8s_adm"
}
output "default_password" {
  value = "${module.aws.secret_key}"
}

output "device" {
  value = "/dev/xvdb"
}
output "cloud_provider" {
  value = "aws"
}
