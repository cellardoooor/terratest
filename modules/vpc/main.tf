terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }
}
resource "yandex_vpc_network" "main" {
  name = "test-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "test-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.0.0.0/24"]
}
