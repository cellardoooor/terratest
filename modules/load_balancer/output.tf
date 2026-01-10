output "lb_ip" {
  value = one([
    for l in yandex_lb_network_load_balancer.this.listener :
    one([
      for a in l.external_address_spec :
      a.address
    ])
  ])
}
