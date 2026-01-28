terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }
}

# Namespace для мониторинга
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.monitoring_namespace
    labels = {
      name = var.monitoring_namespace
    }
  }
}

# Namespace для Zabbix
resource "kubernetes_namespace" "zabbix" {
  metadata {
    name = var.zabbix_namespace
    labels = {
      name = var.zabbix_namespace
    }
  }
}

# Persistent Volume Claims для мониторинга
resource "kubernetes_persistent_volume_claim_v1" "prometheus" {
  metadata {
    name      = "prometheus-storage"
    namespace = var.monitoring_namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "20Gi"
      }
    }
    storage_class_name = var.storage_class_name
  }
}

resource "kubernetes_persistent_volume_claim_v1" "loki" {
  metadata {
    name      = "loki-storage"
    namespace = var.monitoring_namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = var.storage_class_name
  }
}

resource "kubernetes_persistent_volume_claim_v1" "grafana" {
  metadata {
    name      = "grafana-storage"
    namespace = var.monitoring_namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = var.storage_class_name
  }
}

# Persistent Volume Claim для PostgreSQL (Zabbix)
resource "kubernetes_persistent_volume_claim_v1" "postgres" {
  metadata {
    name      = "postgres-storage"
    namespace = var.zabbix_namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = var.storage_class_name
  }
}

# Persistent Volume Claim для Zabbix
resource "kubernetes_persistent_volume_claim_v1" "zabbix" {
  metadata {
    name      = "zabbix-storage"
    namespace = var.zabbix_namespace
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = var.storage_class_name
  }
}

# ConfigMap для Prometheus configuration
resource "kubernetes_config_map_v1" "prometheus_config" {
  metadata {
    name      = "prometheus-config"
    namespace = var.monitoring_namespace
  }

  data = {
    "prometheus.yml" = templatefile("${path.module}/templates/prometheus.yml", {
      namespace = var.monitoring_namespace
    })
  }
}

# ConfigMap для Loki configuration
resource "kubernetes_config_map_v1" "loki_config" {
  metadata {
    name      = "loki-config"
    namespace = var.monitoring_namespace
  }

  data = {
    "loki.yaml" = templatefile("${path.module}/templates/loki.yaml", {
      namespace = var.monitoring_namespace
    })
  }
}

# ConfigMap для Grafana provisioning
resource "kubernetes_config_map_v1" "grafana_provisioning" {
  metadata {
    name      = "grafana-provisioning"
    namespace = var.monitoring_namespace
  }

  data = {
    "datasources.yaml" = templatefile("${path.module}/templates/datasources.yaml", {
      namespace = var.monitoring_namespace
    })
    
    "dashboards.yaml" = templatefile("${path.module}/templates/dashboards.yaml", {
      namespace = var.monitoring_namespace
    })
  }
}

# ConfigMap для Zabbix PostgreSQL configuration
resource "kubernetes_config_map_v1" "postgres_config" {
  metadata {
    name      = "postgres-config"
    namespace = var.zabbix_namespace
  }

  data = {
    "postgresql.conf" = <<-EOF
      max_connections = 200
      shared_buffers = 512MB
      work_mem = 4MB
      maintenance_work_mem = 128MB
      effective_cache_size = 1GB
      checkpoint_completion_target = 0.7
      wal_buffers = 16MB
      default_statistics_target = 100
      random_page_cost = 1.1
      effective_io_concurrency = 200
      work_mem = 4MB
      min_wal_size = 1GB
      max_wal_size = 2GB
      checkpoint_timeout = 10min
      max_wal_size = 1GB
      max_parallel_workers_per_gather = 4
      max_parallel_workers = 8
      max_parallel_maintenance_workers = 2
    EOF
  }
}

# Secret для Zabbix admin user
resource "kubernetes_secret_v1" "zabbix_secret" {
  metadata {
    name      = "zabbix-secret"
    namespace = var.zabbix_namespace
  }

  type = "Opaque"

  data = {
    zabbix-admin-user     = base64encode(var.zabbix_admin_user)
    zabbix-admin-password = base64encode(var.zabbix_admin_password)
  }
}

# Secret для PostgreSQL
resource "kubernetes_secret_v1" "postgres_secret" {
  metadata {
    name      = "postgres-secret"
    namespace = var.zabbix_namespace
  }

  type = "Opaque"

  data = {
    postgres-password = base64encode(var.postgres_password)
  }
}
