output "lb_ip" {
  value = one([
    for l in yandex_lb_network_load_balancer.lb.listener :
    l.external_address_spec[0].address
    if length(l.external_address_spec) > 0
  ])
}
