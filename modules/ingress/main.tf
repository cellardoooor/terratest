# External Load Balancer для Ingress Controller
resource "yandex_lb_network_load_balancer" "ingress" {
  name = "${var.network_name}-ingress-lb"

  listener {
    name = "http"
    port = 80

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  listener {
    name = "https"
    port = 443

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  # Target group для Ingress Controller
  attached_target_group {
    target_group_id = yandex_lb_target_group.ingress.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/healthz"
      }
      interval = 10
      timeout  = 5
      healthy_threshold   = 2
      unhealthy_threshold = 2
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "yandex_lb_target_group" "ingress" {
  name = "${var.network_name}-ingress-targets"

  # Target group будет заполнена через metadata инстансов или автоматически
  # В managed K8s это обычно делается через аннотации Ingress Controller
  # Для простоты создаем пустую target group, которую K8s Controller заполнит
  target {
    subnet_id = var.private_subnet_id
    address   = "0.0.0.0"  # Placeholder, будет заполнено динамически
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
    "use-proxy-protocol"          = "false"
    "proxy-real-ip-cidr"          = var.public_subnet_cidr
    "use-forwarded-headers"       = "true"
    "enable-underscores-in-headers" = "false"
    "log-format-upstream"         = '{"time": "$time_iso8601", "remote_addr": "$remote_addr", "request_method": "$request_method", "request_uri": "$request_uri", "status": $status, "request_time": $request_time, "upstream_response_time": "$upstream_response_time"}'
  }
}

# Secret для TLS (если нужно кастомное TLS)
resource "kubernetes_secret_v1" "tls_secret" {
  metadata {
    name      = "tls-secret"
    namespace = var.ingress_namespace
  }

  type = "kubernetes.io/tls"

  data = {
    "tls.crt" = ""  # Placeholder для будущего использования
    "tls.key" = ""  # Placeholder для будущего использования
  }
}
