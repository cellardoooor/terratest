output "id" {
  description = "Load balancer ID"
  value       = yandex_lb_network_load_balancer.this.id
}

output "name" {
  description = "Load balancer name"
  value       = yandex_lb_network_load_balancer.this.name
}

output "external_ip" {
  description = "Load balancer external IP"
  value = try(
    [for listener in yandex_lb_network_load_balancer.this.listener : 
     listener.external_address_spec[0].address if listener.name == "http"][0],
    null
  )
}

output "target_group_id" {
  description = "Target group ID"
  value       = yandex_lb_target_group.this.id
}