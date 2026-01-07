terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }

  required_version = ">= 1.3.0"
}

# Создаём VPC сеть
resource "yandex_vpc_network" "this" {
  name = "dev-network"
}

# Создаём подсеть внутри сети
resource "yandex_vpc_subnet" "this" {
  name           = "dev-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.cidr]
}
