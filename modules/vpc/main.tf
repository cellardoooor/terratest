terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }

  required_version = ">= 1.3.0"
}

resource "yandex_vpc_network" "this" {
  name = var.network_name
  #lifecycle {
  #  prevent_destroy = true
  #}
}

resource "yandex_vpc_subnet" "this" {
  name           = "${var.network_name}-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.cidr]
  #lifecycle {
  #  prevent_destroy = true
  #}
}

