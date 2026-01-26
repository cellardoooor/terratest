variable "network_name" {
  description = "Name of the network (for security group naming)"
  type        = string
  default     = "platform-network"
}

variable "network_id" {
  description = "ID of the VPC network"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}
