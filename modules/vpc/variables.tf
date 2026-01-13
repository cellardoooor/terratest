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

variable "network_name" {
  description = "Network name"
  type        = string
  default     = "vpc-network"
}

variable "allow_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = []  # пустой список по умолчанию
}