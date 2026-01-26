output "lb_sg_id" {
  description = "ID of the Load Balancer security group"
  value       = yandex_vpc_security_group.load_balancer.id
}

output "k8s_nodes_sg_id" {
  description = "ID of the Kubernetes nodes security group"
  value       = yandex_vpc_security_group.k8s_nodes.id
}
