# ID сети — понадобится VM и LB
output "network_id" {
  value = yandex_vpc_network.this.id
}

# ID подсети — используется для VM
output "subnet_id" {
  value = yandex_vpc_subnet.this.id
}

