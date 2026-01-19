output "load_balancer_security_group_id" {
  value = yandex_vpc_security_group.load_balancer.id
}

output "vm_security_group_id" {
  description = "ID of the VM security group"
  value       = yandex_vpc_security_group.vm.id
}

output "web_open_id" {
  description = "ID of the web_open security group"
  value       = yandex_vpc_security_group.web_open.id
}
