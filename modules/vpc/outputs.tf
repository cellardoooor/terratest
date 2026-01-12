# ID сети — понадобится VM и LB
output "network_id" {
  value = yandex_vpc_network.this.id
}

# ID подсети — используется для VM
output "subnet_id" {
  value = yandex_vpc_subnet.this.id
}

output "load_balancer_security_group_id" {
  value = yandex_vpc_security_group.load_balancer.id
}

output "vm_security_group_id" {
  value = yandex_vpc_security_group.vm.id
}