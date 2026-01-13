variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
}

variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "subnet_id" {
  description = "Subnet ID for VMs"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for VMs"
  type        = list(string)
  default     = []
}

variable "cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory in GB"
  type        = number
  default     = 2
}

variable "disk_size" {
  description = "Boot disk size in GB"
  type        = number
  default     = 2
}

variable "assign_public_ip" {
  description = "Assign public IP to VMs"
  type        = bool
  default     = false
}

variable "ssh_public_key" {
  type      = string
  sensitive = true
}


variable "labels" {
  description = "Labels for VMs"
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "Cloud-init user data"
  type        = string
  default     = ""
}