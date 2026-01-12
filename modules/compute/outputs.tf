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
  value = var.assign_public_ip ? yandex_compute_instance.this[*].network_interface.0.nat_ip_address : []
}


