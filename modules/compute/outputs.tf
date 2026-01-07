# Внутренние IP ВМ — для балансера
output "internal_ips" {
  value = [
    for vm in yandex_compute_instance.this :
    vm.network_interface[0].ip_address
  ]
}
