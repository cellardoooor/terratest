variable "cloud_id" {
  description = "ID of the cloud."
  type        = string
}

variable "folder_id" {
  description = "ID of the folder."
  type        = string
}

variable "zone" {
  description = "Availability zone."
  type        = string
}
variable "sa_key_path" {
  description = "Path to Yandex Cloud service account key"
  type        = string
}
variable "allow_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH (empty for no restrictions in dev)"
  type        = list(string)
  default     = []

  # Для безопасности можно указать:
  # default = ["YOUR_OFFICE_IP/32"]
}

# Опционально: переопределение подсети для dev
variable "cidr" {
  description = "CIDR for dev subnet"
  type        = string
}

variable "service_account_id" {
  description = "Service account ID for instance group"
  type        = string
  default     = "" # или null если поддерживается
}

variable "metadata" {
  description = "Metadata for compute instances (cloud-init, ssh, etc)"
  type        = map(string)
  default     = {}
}
