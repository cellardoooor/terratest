output "load_balancer_external_ip" {
  description = "External IP of the load balancer"
  value       = module.load_balancer.external_ip
}

output "vpc_network_id" {
  description = "VPC Network ID"
  value       = module.vpc.network_id
}

output "subnet_id" {
  description = "Subnet ID"
  value       = module.vpc.subnet_id
}

output "instance_group_id" {
  description = "Instance Group ID"
  value       = module.instance_group.id
}

output "instance_group_ips" {
  description = "Internal IPs of instances in the group"
  value       = module.instance_group.instance_ips
}

output "vm_security_group_id" {
  description = "Security group ID for VMs"
  value       = module.security.vm_security_group_id
}

output "load_balancer_security_group_id" {
  description = "Security group ID for load balancer"
  value       = module.security.load_balancer_security_group_id
}
