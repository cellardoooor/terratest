terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }
}

# Получаем актуальный образ Ubuntu
data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

# Создаём несколько ВМ
resource "yandex_compute_instance" "this" {
  count = var.vm_count

  name = "web-${count.index}"
  zone = var.zone

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = var.disk_size
    }
  }

  # Сетевой интерфейс с security groups
  network_interface {
    subnet_id          = var.subnet_id
    nat                = var.assign_public_ip
    security_group_ids = var.security_group_ids
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }

  labels = var.labels
}

# Cloud-init для автоматической настройки
data "template_cloudinit_config" "config" {
  count = var.user_data != "" ? var.vm_count : 0

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    content      = var.user_data
  }
}