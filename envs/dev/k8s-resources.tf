# Этот файл содержит ресурсы Kubernetes, которые требуют существующего кластера
# Запускается после terraform apply основного конфига

# Для использования этого файла нужно:
# 1. terraform apply main.tf (создает сеть, кластер, LB)
# 2. Найти endpoint кластера
# 3. Настроить kubernetes provider
# 4. terraform apply k8s-resources.tf

provider "kubernetes" {
  host                   = var.k8s_endpoint
  cluster_ca_certificate = var.k8s_ca_certificate
  token                  = var.k8s_token
}

provider "helm" {
  kubernetes {
    host                   = var.k8s_endpoint
    cluster_ca_certificate = var.k8s_ca_certificate
    token                  = var.k8s_token
  }
}

# Модуль Storage (требует Kubernetes провайдер)
module "storage" {
  source = "../../modules/storage"

  zone = var.zone
  kubernetes_namespace = "kube-system"
}

# Модуль Monitoring (требует Kubernetes провайдер)
module "monitoring" {
  source = "../../modules/monitoring"

  monitoring_namespace = var.monitoring_namespace
  zabbix_namespace     = var.zabbix_namespace
  storage_class_name   = module.storage.storage_class_name
  postgres_password    = var.postgres_password
}
