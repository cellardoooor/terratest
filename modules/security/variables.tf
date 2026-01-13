variable "network_id" {
  description = "Existing VPC network ID"
  type        = string
}

variable "cidr" {
  description = "CIDR block of the subnet for security rules"
  type        = string
}

variable "allow_ssh_cidrs" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = []
}

variable "network_name" {
  description = "Prefix for security group names"
  type        = string
  default     = "dev"
}

# Дополнительные параметры
variable "enable_http" {
  description = "Enable HTTP traffic rules"
  type        = bool
  default     = true
}

variable "enable_https" {
  description = "Enable HTTPS traffic rules"
  type        = bool
  default     = true
}