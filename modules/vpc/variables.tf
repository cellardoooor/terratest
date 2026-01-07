# Зона, в которой создаётся подсеть
variable "zone" {
  description = "YC availability zone"
  type        = string
}

# CIDR для подсети
variable "cidr" {
  description = "Subnet CIDR block"
  type        = string
}
