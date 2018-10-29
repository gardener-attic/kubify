### Azure Deployment of Kubernetes

The azure variant for kubernetes is deployed into a predefined azure tenant and subscription.
So far, it uses the AWS route53 service for providing DNS names.


#### Configuration Settings

|Name|Meaning|Optional|
|--|--|--|
|az_client_id|Azure client id|required|
|az_client_secret|Azure client secreat|required|
|az_tenant_id|Azure tenant id|required|
|az_subscription_id|Azure subscription id|required|
|az_region|Azure region name|required|

#### Image Handling

On azure the given image names are quadrupel (<publisher>/<offer>/<sku>/<version>).
