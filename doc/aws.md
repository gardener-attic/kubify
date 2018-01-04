### AWS Deployment of Kubernetes

The AWS variant for kubernetes is deployed into a predefined AWS account.
Is uses an own VPC for the cluster, which is automatically created.
So far, it uses the AWS route53 service for providing DNS names.


#### Configuration Settings

|Name|Meaning|Optional|
|--|--|--|
|aws_access_key|AWS access key|required|
|aws_secret_key|AWS secret key|required|
|aws_region|AWS region|required|
|aws_availability_zone|Character for denoting the availability zone (for example `a`)|required|
|aws_kube2iam_roles|List of IAM role specification to grant AWS API access for pods|optional|
|aws_vpc_cidr|VPC IP range (default: 10.250.0.0/16)|optional|
|aws_public_subnet_cidr|IP range for public subnet in VPC, defaulted by subrange of `aws_vpc_cidr`|optional|

##### Format for IAM role settings
i The AWS variant uses a dedicated daemon set (`kube2iam`) to restrict the usage of the instance
profile by kubernetes deployments. By default its is completely prohibited. If there are deployments
that require access to the AWS API using the standard AWS instance profile mechanism, dedicated
roles can be specified via configuration. The required trust relation is automatically generated.
[kube2iam](https://github.com/jtblin/kube2iam/blob/master/README.md)
then provides IAM credentials to pods based on annotations.

The role settings are specified by a list where every entry has the following map layout:

|Field|Meaning|Optional|
|--|--|--|
|name|name of the role|required|
|description|content for the description field of the role|required|
|policy|IAM policy document in json format|required|

Example:
```
[
  { name= "ecr.mycomponent"
    description= "Allow access to ECR repositories beginning with 'mycomponent/', and creation of new repositories"
    policy= <<EOF
{
              "Version": "2012-10-17",
              "Statement": [
                {
                  "Action": "ecr:*",
                  "Effect": "Allow",
                  "Resource": "arn:aws:ecr:eu-central-1:${account_id}:repository/mycomponent/*"
                },
                {
                  "Action": [
                    "ecr:GetAuthorizationToken",
                    "ecr:CreateRepository"
                  ],
                  "Effect": "Allow",
                  "Resource": "*"
                }
              ]
}
EOF
  }
]
```

#### Image Handling

On azure the given image names are used as prefix filters (<name>-*) for looking up the latest image by name.
