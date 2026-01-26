output "monitoring_namespace" {
  description = "Namespace for monitoring stack"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "zabbix_namespace" {
  description = "Namespace for Zabbix"
  value       = kubernetes_namespace.zabbix.metadata[0].name
}

output "prometheus_pvc_name" {
  description = "Prometheus PVC name"
  value       = kubernetes_persistent_volume_claim_v1.prometheus.metadata[0].name
}

output "loki_pvc_name" {
  description = "Loki PVC name"
  value       = kubernetes_persistent_volume_claim_v1.loki.metadata[0].name
}

output "grafana_pvc_name" {
  description = "Grafana PVC name"
  value       = kubernetes_persistent_volume_claim_v1.grafana.metadata[0].name
}

output "postgres_pvc_name" {
  description = "PostgreSQL PVC name"
  value       = kubernetes_persistent_volume_claim_v1.postgres.metadata[0].name
}
