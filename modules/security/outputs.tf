output "load_balancer_security_group_id" {
  value = yandex_vpc_security_group.load_balancer.id
}

output "vm_security_group_id" {
  value = yandex_vpc_security_group.vm.id
}