terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

variable "vpc_id" {
  description = "Subnet ID for compute instances"
  type        = string
}

variable "zone" {
  description = "Availability zone"
  type        = string
}

resource "yandex_compute_instance" "web_server1" {
  name        = "web-server1"
  zone        = var.zone
  platform_id = "standard-v2"
  subnet_id   = var.vpc_id
  resources {
    cores   = 2
    memory  = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kq5t2nq36pl6k2tdt" # Ubuntu 20.04 LTS
    }
  }

  network_interface {
    subnet_id = var.vpc_id
    nat       = true
  }
}

resource "yandex_compute_instance" "web_server2" {
  name        = "web-server2"
  zone        = var.zone
  platform_id = "standard-v2"
  subnet_id   = var.vpc_id
  resources {
    cores   = 2
    memory  = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kq5t2nq36pl6k2tdt" # Ubuntu 20.04 LTS
    }
  }

  network_interface {
    subnet_id = var.vpc_id
    nat       = true
  }
}

output "web_server1_ip" {
  value = yandex_compute_instance.web_server1.network_interface.0.ip_address
}

output "web_server2_ip" {
  value = yandex_compute_instance.web_server2.network_interface.0.ip_address
}
