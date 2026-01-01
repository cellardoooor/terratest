output "web_server1_ip" {
  value = yandex_compute_instance.web_server1.network_interface[0].ip_address
}

output "web_server2_ip" {
  value = yandex_compute_instance.web_server2.network_interface[0].ip_address
}
