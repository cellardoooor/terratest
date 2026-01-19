output "ids" {
  value = yandex_compute_instance.this[*].id
}
output "names" {
  value = yandex_compute_instance.this[*].name
}

output "internal_ips" {
  value = yandex_compute_instance.this[*].network_interface.0.ip_address
}

output "external_ips" {
  description = "External IP addresses of the instances"
  value       = [for vm in yandex_compute_instance.this : vm.network_interface[0].nat_ip_address]
}

output "instances" {
  description = "All instances data"
  value       = yandex_compute_instance.this
}