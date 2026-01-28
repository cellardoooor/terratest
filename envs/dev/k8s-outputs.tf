# Storage outputs (только после развертывания в кластере)
output "ingress_namespace" {
  description = "Ingress namespace (k8s-resources)"
  value       = var.ingress_namespace
}

output "ingress_lb_service" {
  description = "Ingress LoadBalancer service name"
  value       = "ingress-nginx-controller"
}
