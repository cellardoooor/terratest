variable "network_name" {
  description = "Name of the network"
  type        = string
  default     = "platform-network"
}

variable "public_subnet_id" {
  description = "Public subnet ID for LB targets"
  type        = string
}

variable "private_subnet_id" {
  description = "Private subnet ID for internal targets"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "ingress_namespace" {
  description = "Kubernetes namespace for ingress controller"
  type        = string
  default     = "ingress-nginx"
}
