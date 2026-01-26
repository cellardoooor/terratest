# Storage outputs (только после развертывания в кластере)
output "storage_class_name" {
  description = "StorageClass name (from storage module)"
  value       = module.storage.storage_class_name
}

# Monitoring outputs (только после развертывания в кластере)
output "monitoring_namespace" {
  description = "Monitoring namespace"
  value       = module.monitoring.monitoring_namespace
}

output "zabbix_namespace" {
  description = "Zabbix namespace"
  value       = module.monitoring.zabbix_namespace
}

output "prometheus_pvc_name" {
  description = "Prometheus PVC name"
  value       = module.monitoring.prometheus_pvc_name
}

output "loki_pvc_name" {
  description = "Loki PVC name"
  value       = module.monitoring.loki_pvc_name
}

output "grafana_pvc_name" {
  description = "Grafana PVC name"
  value       = module.monitoring.grafana_pvc_name
}

output "postgres_pvc_name" {
  description = "PostgreSQL PVC name"
  value       = module.monitoring.postgres_pvc_name
}

output "ingress_namespace" {
  description = "Ingress namespace (k8s-resources)"
  value       = var.ingress_namespace
}

output "ingress_lb_service" {
  description = "Ingress LoadBalancer service name"
  value       = "ingress-nginx-controller"
}
