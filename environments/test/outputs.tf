output "vpc_network_id" {
  value = module.vpc.network_id
}

output "vm_external_ips" {
  description = "External IP addresses of VMs"
  value       = module.compute.external_ips # используем output из модуля compute
}

# Вывод имен ВМ с их IP
output "vm_details" {
  description = "VM names with their IP addresses"
  value = {
    for idx, vm in module.compute.instances :
    vm.name => {
      internal_ip = vm.network_interface[0].ip_address
      external_ip = vm.network_interface[0].nat_ip_address
    }
  }
}

output "vm_network_info" {
  value = {
    for idx, vm in module.compute.instances :
    vm.name => {
      has_nat    = vm.network_interface[0].nat
      nat_ip     = vm.network_interface[0].nat_ip_address
      private_ip = vm.network_interface[0].ip_address
    }
  }
  description = "Check if NAT is enabled and IP addresses"
}
