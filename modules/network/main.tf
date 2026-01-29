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

# Public subnet for NAT Gateway and Load Balancer
resource "yandex_vpc_subnet" "public" {
  name           = "${var.network_name}-public"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

# Private subnet for Kubernetes worker nodes
resource "yandex_vpc_subnet" "private" {
  name           = "${var.network_name}-private"
  zone           = var.zone
  network_id     = yandex_vpc_network.this.id
  v4_cidr_blocks = [var.private_subnet_cidr]
  route_table_id = yandex_vpc_route_table.private.id
}

# NAT Gateway for private subnet to access internet
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "${var.network_name}-nat-gateway"
  shared_egress_gateway {}
}

# Route table for private subnet to route traffic through NAT
resource "yandex_vpc_route_table" "private" {
  name       = "${var.network_name}-private-routes"
  network_id = yandex_vpc_network.this.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
