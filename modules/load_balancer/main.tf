terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }

  required_version = ">= 1.3.0"
}

# Балансер нагрузки
resource "yandex_lb_network_load_balancer" "this" {
  name = "dev-lb"

  listener {
    name = "http"
    port = 80

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.this.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
      }
    }
  }
}

# Группа таргетов (ВМ)
resource "yandex_lb_target_group" "this" {
  dynamic "target" {
    for_each = var.targets
    content {
      subnet_id = var.subnet_id
      address   = target.value
    }
  }
}
