output "ids" {
  description = "VM IDs"
  value       = yandex_compute_instance.this[*].id
}

output "names" {
  description = "VM names"
  value       = yandex_compute_instance.this[*].name
}

output "internal_ips" {
  description = "Internal IP addresses"
  value       = yandex_compute_instance.this[*].network_interface.0.ip_address
}

output "external_ips" {
  description = "External IP addresses (if NAT enabled)"
  value       = var.assign_public_ip ? yandex_compute_instance.this[*].network_interface.0.nat_ip_address : []
}