output "lb_ip" {
  description = "Load Balancer external IP address"
  value       = try(
    [for listener in yandex_lb_network_load_balancer.ingress.listener : 
     listener.external_address_spec[0].address if listener.name == "http"][0],
    null
  )
}

output "lb_id" {
  description = "Load Balancer ID"
  value       = yandex_lb_network_load_balancer.ingress.id
}

output "ingress_namespace" {
  description = "Kubernetes namespace for Ingress Controller"
  value       = var.ingress_namespace
}

output "ingress_service_name" {
  description = "Ingress Controller service name"
  value       = "ingress-nginx-controller"
}
