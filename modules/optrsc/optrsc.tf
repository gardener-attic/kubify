variable "value" {
  type = "list"
}

variable "default" {
  default = ""
}

output "value" {
  value = "${element(concat(var.value,list(var.default)),0)}"
}
