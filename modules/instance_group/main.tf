terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance_group" "this" {
  name               = var.name
  service_account_id = var.service_account_id
  instance_template {
    platform_id = "standard-v3"
    
    resources {
      memory = var.memory
      cores  = var.cores
    }
    
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        size     = max(var.disk_size, 8)  # минимум 8GB
      }
    }
    
    network_interface {
      network_id = var.network_id
      subnet_ids = var.subnet_ids
      nat        = var.assign_public_ip
      security_group_ids = var.security_group_ids
    }
    
   metadata = {
  ssh-keys = "ubuntu:${var.ssh_public_key}"
}
    
    labels = var.labels
  }
  
  scale_policy {
    fixed_scale {
      size = var.size  # количество инстансов в группе
    }
  }
  
  allocation_policy {
    zones = var.zones
  }
  
  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
  
  load_balancer {
    target_group_name = var.target_group_name
  }
  
  # Health checks для балансировщика
  health_check {
    interval = 30
    timeout  = 10
    unhealthy_threshold = 5
    healthy_threshold   = 3
    
    http_options {
      port = 80
      path = var.health_check_path
    }
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# Если нужна отдельная target group
resource "yandex_lb_target_group" "this" {
  name = var.target_group_name
  
  target {
    subnet_id = var.subnet_ids[0]
    address   = yandex_compute_instance_group.this.instances[0].network_interface[0].ip_address
  }
  
  # Добавить больше targets при необходимости
  dynamic "target" {
    for_each = slice(yandex_compute_instance_group.this.instances, 1, length(yandex_compute_instance_group.this.instances))
    content {
      subnet_id = var.subnet_ids[0]
      address   = target.value.network_interface[0].ip_address
    }
  }
}