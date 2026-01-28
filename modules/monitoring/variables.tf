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

variable "storage_class_name" {
  description = "StorageClass name for PVCs"
  type        = string
  default     = "yandex-network-ssd"
}

variable "postgres_password" {
  description = "PostgreSQL admin password for Zabbix"
  type        = string
  sensitive   = true
}

variable "zabbix_admin_user" {
  description = "Zabbix admin username"
  type        = string
  sensitive   = false
  default     = "Admin"
}

variable "zabbix_admin_password" {
  description = "Zabbix admin password"
  type        = string
  sensitive   = true
}
