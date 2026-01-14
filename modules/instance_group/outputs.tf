output "id" {
  description = "Instance group ID"
  value       = yandex_compute_instance_group.this.id
}

output "name" {
  description = "Instance group name"
  value       = yandex_compute_instance_group.this.name
}

output "instances" {
  description = "List of instances in the group"
  value       = yandex_compute_instance_group.this.instances
}

output "instance_ips" {
  description = "Internal IP addresses of instances"
  value = [for instance in yandex_compute_instance_group.this.instances : 
           instance.network_interface[0].ip_address]
}

output "instance_group_id" {
  value       = yandex_lb_target_group.this.id
}

output "load_balancer_target_group_name" {
  description = "Target group name"
  value       = yandex_compute_instance_group.this.load_balancer[0].target_group_name
}