output "load_balancer_external_ip" {
  value = module.load_balancer.external_ip
}

output "vpc_network_id" {
  value = module.vpc.network_id
}

output "instance_group_id" {
  value = module.instance_group.instance_group_id
}