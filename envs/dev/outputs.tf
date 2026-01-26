# Network outputs
output "vpc_id" {
  description = "VPC Network ID"
  value       = module.network.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.network.public_subnet_id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.network.private_subnet_id
}

# Security Group outputs
output "lb_sg_id" {
  description = "Load Balancer security group ID"
  value       = module.security_groups.lb_sg_id
}

output "k8s_nodes_sg_id" {
  description = "Kubernetes nodes security group ID"
  value       = module.security_groups.k8s_nodes_sg_id
}

# Kubernetes Cluster outputs
output "cluster_id" {
  description = "Kubernetes cluster ID"
  value       = module.kubernetes_cluster.cluster_id
}

output "cluster_endpoint" {
  description = "Kubernetes cluster endpoint"
  value       = module.kubernetes_cluster.cluster_endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Kubernetes cluster CA certificate"
  value       = module.kubernetes_cluster.cluster_ca_certificate
  sensitive   = true
}

output "node_group_id" {
  description = "Worker node group ID"
  value       = module.kubernetes_cluster.node_group_id
}

# Ingress outputs
output "lb_ip" {
  description = "Load Balancer external IP"
  value       = module.ingress.lb_ip
}
