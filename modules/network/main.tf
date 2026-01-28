terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }
}

resource "yandex_vpc_network" "this" {
  name = var.network_name
}

resource "yandex_vpc_subnet" "public" {
  name           = "${var.network_name}-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

resource "yandex_vpc_subnet" "private" {
  name           = "${var.network_name}-private"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.private_subnet_cidr]
  
  # Private subnet без NAT (только для внутренних ресурсов)
  # Для доступа в интернет нужно использовать NAT gateway или общие правила
}
