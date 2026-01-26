# Общие переменные
variable "zone" {
  description = "Yandex Cloud zone"
  type        = string
  default     = "ru-central1-a"
}

variable "sa_key_path" {
  description = "Path to Yandex Cloud service account key file"
  type        = string
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Cloud folder ID"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID for Kubernetes cluster"
  type        = string
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

# Network variables
variable "network_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "platform-network"
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

# Kubernetes cluster variables
variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "platform-cluster"
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

# Ingress variables
variable "ingress_namespace" {
  description = "Namespace for ingress controller"
  type        = string
  default     = "ingress-nginx"
}

# Monitoring variables
variable "monitoring_namespace" {
  description = "Namespace for monitoring stack"
  type        = string
  default     = "monitoring"
}

variable "zabbix_namespace" {
  description = "Namespace for Zabbix"
  type        = string
  default     = "zabbix"
}

variable "postgres_password" {
  description = "PostgreSQL admin password for Zabbix"
  type        = string
  sensitive   = true
  default     = "zabbix123"
}

# Ingress variables (для k8s-resources.tf)
variable "public_subnet_id" {
  description = "Public subnet ID (from network module)"
  type        = string
  default     = ""
}

# Kubernetes provider variables (для k8s-resources.tf)
variable "k8s_endpoint" {
  description = "Kubernetes cluster endpoint (from cluster module output)"
  type        = string
  default     = ""
}

variable "k8s_ca_certificate" {
  description = "Kubernetes cluster CA certificate (from cluster module output)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "k8s_token" {
  description = "Kubernetes cluster token (for authentication)"
  type        = string
  default     = ""
  sensitive   = true
}
