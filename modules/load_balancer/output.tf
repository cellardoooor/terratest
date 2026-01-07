# Публичный IP балансера
output "lb_ip" {
  value = yandex_lb_network_load_balancer.this.listener[0].external_address_spec[0].address
}
