
module "domain_check" {
  source = "../../../../modules/config_check"
  values = [ "${module.domain_id.value}", "${module.domain_name.value}" ]
  buddies= [ "OS_PROJECT_DOMAIN_ID", "OS_PROJECT_DOMAIN_NAME" ]
  message= "please specify either os_domain_name or os_domain_id"
}
module "tenant_check" {
  source = "../../../../modules/config_check"
  values = [ "${module.tenant_id.value}", "${module.tenant_name.value}" ]
  buddies= [ "OS_TENANT_ID", "OS_TENANT_NAME" ]
  message= "please specify either os_tenant_name or os_tenant_id"
}

output "domain_key" {
  value = "${module.domain_check.buddy}"
}
output "domain_value" {
  value = "${module.domain_check.value}"
}

output "tenant_key" {
  value = "${module.tenant_check.buddy}"
}
output "tenant_value" {
  value = "${module.tenant_check.value}"
}

locals {
  keys= {
    "OS_PROJECT_DOMAIN_NAME" = "OS_USER_DOMAIN_NAME"
    "OS_PROJECT_DOMAIN_ID" = "OS_USER_DOMAIN_ID"
  }
}

output "user_domain_key" {
  value = "${local.keys[module.domain_check.buddy]}"
}
output "user_domain_value" {
  value = "${module.domain_check.value}"
}
