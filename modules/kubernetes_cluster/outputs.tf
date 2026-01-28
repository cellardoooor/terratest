output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = yandex_kubernetes_cluster.this.id
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  value       = yandex_kubernetes_cluster.this.master[0].external_v4_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate of the Kubernetes cluster"
  value       = yandex_kubernetes_cluster.this.master[0].cluster_ca_certificate
  sensitive   = true
}


output "node_group_id" {
  description = "ID of the worker node group"
  value       = yandex_kubernetes_node_group.workers.id
}
