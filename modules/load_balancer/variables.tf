variable "subnet_id" {
  type = string
}

variable "targets" {
  description = "Internal IPs of backend VMs"
  type        = list(string)
}
