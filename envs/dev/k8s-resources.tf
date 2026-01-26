# Этот файл содержит ресурсы Kubernetes, которые требуют существующего кластера
# Запускается после terraform apply основного конфига

# Для использования этого файла нужно:
# 1. terraform apply main.tf (создает сеть, кластер, LB)
# 2. Получить endpoint кластера через terraform output
# 3. Настроить kubernetes provider
# 4. terraform apply -var-file="k8s.tfvars" k8s-resources.tf

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

# Namespace для Ingress Controller
resource "kubernetes_namespace" "ingress" {
  metadata {
    name = var.ingress_namespace
  }
}

# ConfigMap для NGINX Ingress Controller (базовая конфигурация)
resource "kubernetes_config_map_v1" "nginx_config" {
  metadata {
    name      = "nginx-configuration"
    namespace = var.ingress_namespace
  }

  data = {
    "use-proxy-protocol"            = "false"
    "proxy-real-ip-cidr"            = var.public_subnet_cidr
    "use-forwarded-headers"         = "true"
    "enable-underscores-in-headers" = "false"
    "log-format-upstream"           = "{\"time\": \"$time_iso8601\", \"remote_addr\": \"$remote_addr\", \"request_method\": \"$request_method\", \"request_uri\": \"$request_uri\", \"status\": $status, \"request_time\": $request_time, \"upstream_response_time\": \"$upstream_response_time\"}"
  }
}

# Secret для TLS (будет использоваться при необходимости)
resource "kubernetes_secret_v1" "tls_secret" {
  metadata {
    name      = "tls-secret"
    namespace = var.ingress_namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = ""  # Placeholder - заполнить при необходимости
    "tls.key" = ""  # Placeholder - заполнить при необходимости
  }
}

# Service для Ingress Controller (LoadBalancer type)
# Аннотация указывает Yandex Cloud использовать публичную подсеть
resource "kubernetes_service_v1" "ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = var.ingress_namespace
    annotations = {
      "service.beta.kubernetes.io/yandex-load-balancer-external-subnet-id" = var.public_subnet_id
      "service.beta.kubernetes.io/yandex-load-balancer-type"               = "external"
    }
  }

  spec {
    type = "LoadBalancer"
    
    selector = {
      app.kubernetes.io/name    = "ingress-nginx"
      app.kubernetes.io/instance = "ingress-nginx"
    }

    port {
      name       = "http"
      port       = 80
      protocol   = "TCP"
      target_port = "80"
    }

    port {
      name       = "https"
      port       = 443
      protocol   = "TCP"
      target_port = "443"
    }
  }
}

# Модуль Storage (требует Kubernetes провайдер)
# Использует storage_class из модуля storage
module "storage" {
  source = "../../modules/storage"

  zone = var.zone
  kubernetes_namespace = "kube-system"

  depends_on = [module.network]
}

# Модуль Monitoring (требует Kubernetes провайдер)
# Использует storage класс из storage модуля
module "monitoring" {
  source = "../../modules/monitoring"

  monitoring_namespace = var.monitoring_namespace
  zabbix_namespace     = var.zabbix_namespace
  storage_class_name   = module.storage.storage_class_name
  postgres_password    = var.postgres_password

  # Ждем пока StorageClass создастся
  depends_on = [module.storage]
}
