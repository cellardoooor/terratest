terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }
}
resource "yandex_lb_network_load_balancer" "lb" {
  name = "web-nlb"

  listener {
    name        = "http-listener"
    port        = 80
    target_port = 80
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.tg.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}

resource "yandex_lb_target_group" "tg" {
  name = "web-target-group"

  target {
    subnet_id = var.subnet_id
    address   = var.web_server_ips[0]
  }

  target {
    subnet_id = var.subnet_id
    address   = var.web_server_ips[1]
  }
}
