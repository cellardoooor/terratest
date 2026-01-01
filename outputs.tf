output "vpc_id" {
  value       = module.vpc.network_id
  description = "ID of created VPC"
}

output "subnet_id" {
  value       = module.vpc.subnet_id
  description = "ID of created Subnet"
}

output "load_balancer_ip" {
  value = module.load_balancer.lb_ip
}