variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "platform-cluster"
}

variable "network_id" {
  description = "VPC network ID"
  type        = string
}

variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "private_subnet_id" {
  description = "Private subnet ID for nodes"
  type        = string
}

variable "k8s_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 3
}

variable "worker_cores" {
  description = "CPU cores for worker nodes"
  type        = number
  default     = 4
}

variable "worker_memory" {
  description = "Memory in GB for worker nodes"
  type        = number
  default     = 16
}

variable "service_account_id" {
  description = "Service account ID for cluster"
  type        = string
}

variable "master_security_group_ids" {
  description = "Security groups for master nodes"
  type        = list(string)
  default     = []
}

variable "node_security_group_ids" {
  description = "Security groups for worker nodes"
  type        = list(string)
  default     = []
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
}

variable "ssh_user" {
  description = "SSH user"
  type        = string
  default     = "ubuntu"
}
