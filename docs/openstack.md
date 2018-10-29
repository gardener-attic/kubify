### Openstack Deployment of Kubernetes

The openstack variant for kubernetes is deployed into a predefined openstack tenant.
So far, it uses the AWS route53 service for providing DNS names.


#### Configuration Settings

|Name|Meaning|Optional|
|--|--|--|
|os_auth_url|Openstack API endpoint (V3) for accessing the openstack environment|required|
|os_domain_name|Openstack domain name to use for the cluster|one of os_domain_id or os_domain_name required|
|os_domain_id|Openstack domain id to use for the cluster|one of os_domain_id or os_domain_name required|
|os_tenant_name|Openstack tenant name to use for the cluster|one of os_tenant_id or os_tenant_name required|
|os_tenant_id|Openstack tenant id to use for the cluster|one of os_tenant_id or os_tenant_name required|
|os_region|Openstack region identifier to use for the cluster|required|
|os_az|Openstack availability zone to use for the cluster|required|
|os_user_name|Openstack user name for accessing the openstack api|required|
|os_password|Openstack password for the given user|required|
|os_fip_pool_name|Pool name to be used for floating IPs (network name)|required|
|os_lbaas_provider|Name of the openstack load balancer provider to use|optional| 
|os_lbaas_subnet_id|Id of the subnet used to deploy the load balancer. The default is the subnet used for the cluster nodes|optional|
|os_lbaas_pool_name|Pool name to be used for floating IPs for the load balancer. The default is the FIP pool name (network name)|optional|
|os_device_name|device name used on VMs for the first data volume|optional (default `/dev/vdb`)|
|os_vaz|Openstack availability zone to use for volumes|optional|

#### Image Handling

On openstack the given image names are directly used to lookup the images (see `glance`). The `bin/os` folder 
provides a script (`os_image`) that can be used to upload an appropriate coreos image.

The expected image names are by default:
- `ubuntu-16.04` for the bastion host
- `coreos-`<version> for the cluster nodes 

The image for the bastion can be chossen arbitrarily, but the expected user is `ubuntu`. It
can be changed by specifying the `user_name` atributte for the `bastion` settings in `terraform.tfvars`

The node image *MUST* always be a coreos image.
