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


resource "aws_iam_role" "role" {
  count = "${length(module.aws.kube2iam_roles)}"
  name  = "${var.prefix}-${lookup(module.aws.kube2iam_roles[count.index], "name")}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${aws_iam_role.worker.arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

data "aws_caller_identity" "identity" {}

data "template_file" "policy" {
  template = "${lookup(module.aws.kube2iam_roles[count.index], "policy")}"
  vars {
    account_id = "${data.aws_caller_identity.identity.account_id}"
  }
}

resource "local_file" "policy" {
  count = 0
  filename = "debug-policy"
  content  = "${data.template_file.policy.rendered}"
}

resource "aws_iam_policy" "policy" {
  count        = "${length(module.aws.kube2iam_roles)}"
  name         = "${var.prefix}-${lookup(module.aws.kube2iam_roles[count.index], "name")}"
  description  = "${lookup(module.aws.kube2iam_roles[count.index], "description")}"
  policy       = "${data.template_file.policy.rendered}"
}

resource "aws_iam_role_policy_attachment" "role-attach" {
  count      = "${length(module.aws.kube2iam_roles)}"
  role       = "${element(aws_iam_role.role.*.name, count.index)}"
  policy_arn = "${element(aws_iam_policy.policy.*.arn, count.index)}"
}

