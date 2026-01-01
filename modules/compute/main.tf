terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }
}


resource "yandex_compute_instance" "web_server1" {
  name        = "web-server1"
  zone        = var.zone
  platform_id = "standard-v2"

  resources {
    cores  = 1
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }
}

resource "yandex_compute_instance" "web_server2" {
  name        = "web-server2"
  zone        = var.zone
  platform_id = "standard-v2"

  resources {
    cores  = 1
    memory = 1
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }
}
