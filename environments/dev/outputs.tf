output "load_balancer_external_ip" {
  value = module.load_balancer.external_ip
}

output "vm_internal_ips" {
  value = module.compute.internal_ips
}

output "vpc_network_id" {
  value = module.vpc.network_id
}