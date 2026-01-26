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

  # Для Yandex Managed K8s, LoadBalancer Service автоматически добавляет ноды
  # в целевую группу через cloud controller manager
  # Эта target group будет заполнена динамически
  target {
    subnet_id = var.private_subnet_id
    address   = "0.0.0.0"  # Placeholder, заполняется автоматически
  }
}
