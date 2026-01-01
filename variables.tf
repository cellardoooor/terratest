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