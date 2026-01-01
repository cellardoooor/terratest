terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_vpc_network" "main" {
  name = "test-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name       = "test-subnet"
  zone       = var.zone
  network_id = yandex_vpc_network.main.id
  cidr_block = "10.0.0.0/24"
  gateway_id = yandex_vpc_network.main.default_gateway_id
}

output "network_id" {
  value = yandex_vpc_network.main.id
}
output "subnet_id" {
  value = yandex_vpc_subnet.subnet.id
  description = "ID of created Subnet"
}