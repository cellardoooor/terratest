variable "name" {
  description = "Instance group name"
  type        = string
  default     = "web-instance-group"
}

variable "size" {
  description = "Number of instances in the group"
  type        = number
  default     = 2
}

variable "zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["ru-central1-a"]
}

variable "subnet_ids" {
  description = "Subnet IDs for instances"
  type        = list(string)
}

variable "network_id" {
  description = "Network ID"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
  default     = []
}

variable "cores" {
  description = "Number of CPU cores per instance"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in GB per instance"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 10
}

variable "assign_public_ip" {
  description = "Assign public IP to instances"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  description = "SSH public key content (not path!)"  # ← исправить описание
  type        = string
  default     = ""  # пустая строка
}

variable "labels" {
  description = "Labels for instances"
  type        = map(string)
  default     = {}
}

variable "service_account_id" {
  description = "Service account ID for instances"
  type        = string
  default     = null
}

variable "target_group_name" {
  description = "Target group name for load balancer"
  type        = string
  default     = "web-targets"
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}