terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }

  required_version = ">= 1.3.0"
}
# Security group для балансировщика
resource "yandex_vpc_security_group" "load_balancer" {
  name        = "${var.network_name}-lb-sg"
  description = "Security group for load balancer"
  network_id  = var.network_id

  # 1. Балансировщик принимает HTTP/HTTPS из интернета
  ingress {
    protocol       = "TCP"
    description    = "HTTP from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS from internet"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # 2. Балансировщик может ходить на VM по любым портам
  egress {
    protocol       = "ANY"
    description    = "LB to VMs"
    v4_cidr_blocks = [var.cidr]  # Только к нашим VM!
  }
}

# Security group для VM (backend инстансов)
resource "yandex_vpc_security_group" "vm" {
  name        = "${var.network_name}-vm-sg"
  description = "Security group for backend instances"
  network_id  = var.network_id

  # 1. VM принимают трафик ТОЛЬКО от балансировщика
  ingress {
    protocol          = "ANY"
    description       = "From load balancer only"
    security_group_id = yandex_vpc_security_group.load_balancer.id
  }

  # 2. SSH только из указанных сетей (опционально)
  dynamic "ingress" {
    for_each = var.allow_ssh_cidrs
    content {
      protocol       = "TCP"
      description    = "SSH from trusted IPs"
      v4_cidr_blocks = [ingress.value]
      port           = 22
    }
  }

  # 3. VM могут ходить в интернет (обновления)
  egress {
    protocol       = "TCP"
    description    = "Outbound HTTP for updates"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  egress {
    protocol       = "TCP"
    description    = "Outbound HTTPS for updates"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  # 4. DNS
  egress {
    protocol       = "UDP"
    description    = "DNS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 53
  }
}

# security-groups.tf
resource "yandex_vpc_security_group" "web_open" {
  name        = "web-open-all"
  description = "Open web ports for testing"
  network_id  = var.network_id

  # Входящие правила (ingress)
  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 80
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP Alternative"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 8080
  }

  # Исходящие правила (egress) - разрешаем всё
  egress {
    protocol       = "ANY"
    description    = "Allow all outbound"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Добавляем SSH для управления (опционально)
  ingress {
    protocol       = "TCP"
    description    = "SSH"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 22
  }
}