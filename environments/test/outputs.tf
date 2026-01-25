output "vpc_network_id" {
  value = module.vpc.network_id
}

output "vm_ip_address" {
  description = "Internal IP address of the VM"
  value       = try(module.compute.internal_ips[0], null)
}

output "vm_security_group_id" {
  description = "Security group ID for VMs"
  value       = module.security.vm_security_group_id
}

output "load_balancer_id" {
  description = "Load balancer ID"
  value       = module.load_balancer.id
}

output "load_balancer_external_ip" {
  description = "Load balancer external IP"
  value       = module.load_balancer.external_ip
}
