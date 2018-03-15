
variable "dns" {
  type = "map"
}

locals {
  dns_type = "${lookup(var.dns,"dns_type", "")}"
}


module "route53_dns" {
  source = "../flag"
  option = "${local.dns_type == "route53"}"
}

module "route53_access_info" {
  source = "../lookup_map"
  map = "${var.access_info}"
  key = "route53_dns"
}
module "route53_access" {
  source = "../access/aws"
  access_info = "${module.route53_access_info.value}"
} 

module "dns_access_info" {
  source = "../mapvar"
  value = "${merge(module.route53_access_info.value,var.dns)}"
}

