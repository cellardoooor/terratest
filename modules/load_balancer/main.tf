terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "vpc_id" {
  description = "VPC/network id"
  type        = string
}

variable "folder_id" {
  description = "Folder id"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
}
variable "web_server_ips" {
  description = "IPs of web servers"
  type        = list(string)
}
resource "yandex_lb_network_load_balancer" "lb" {
  name      = "test-lb"
  folder_id = var.folder_id
  zone      = var.zone
  network_id = var.vpc_id

  listener {
    port = 80
    external_address = true
  }

  backend_group {
    backend {
      address = var.web_server_ips[0]
      port    = 80
    }
    backend {
      address = var.web_server_ips[1]
      port    = 80
    }
  }
}

output "lb_ip" {
  value = yandex_lb_network_load_balancer.lb.listener[0].external_address
}
