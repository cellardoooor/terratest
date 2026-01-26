variable "zone" {
  description = "Yandex Cloud zone for storage"
  type        = string
  default     = "ru-central1-a"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for storage config"
  type        = string
  default     = "kube-system"
}
