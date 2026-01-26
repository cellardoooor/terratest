# Создание Kubernetes кластера
resource "yandex_kubernetes_cluster" "this" {
  name = "${var.cluster_name}-k8s"

  network_id = var.network_id

  # Master node настройки
  master {
    version = var.k8s_version
    public_ip = false

    # Zone для master
    zone = var.zone
    
    # Security group для master
    security_group_ids = var.master_security_group_ids
    
    # Internal load balancer для API
    internal_load_balancer {
      subnet_ids = [var.private_subnet_id]
    }
  }

  # Service account для кластера
  service_account_id = var.service_account_id

  # Node group будет создан отдельно
  
  # Подключение через ресурсы не требуется (managed service)
}

# Node group для worker nodes
resource "yandex_kubernetes_node_group" "workers" {
  name    = "worker-nodes"
  version = var.k8s_version
  cluster_id = yandex_kubernetes_cluster.this.id

  # Спецификация нод
  instance_template {
    name = "worker-{instance.index}"

    resources {
      cores  = var.worker_cores
      memory = var.worker_memory
    }

    boot_disk {
      type = "network-ssd"
      size = 64  # GB
    }

    network_interface {
      subnet_ids = [var.private_subnet_id]
      nat        = false
      security_group_ids = var.node_security_group_ids
    }

    # Конфигурация метаданных
    metadata = {
      ssh-keys = "${var.ssh_user}:${file(var.ssh_public_key_path)}"
    }

    scheduling_policy {
      preemptible = false
    }
  }

  scale_policy {
    fixed_scale {
      size = var.worker_count
    }
  }

  # Размещение в одной зоне
  allocation_policy {
    location {
      zone = var.zone
    }
  }

  # Механизм обновления
  upgrade_policy {
    max_expansion   = 1
    max_unavailable = 0
  }
}
