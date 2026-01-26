# StorageClass для Yandex Disk (Network SSD)
resource "kubernetes_storage_class_v1" "this" {
  metadata {
    name = "yandex-network-ssd"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  
  # Yandex Cloud CSI driver provisioner
  provisioner = "yandex.csi.flant.com"
  
  # Parameters
  parameters = {
    type = "network-ssd"
    fsType = "ext4"
  }
  
  # Volume expansion support
  allow_volume_expansion = true
  
  # Reclaim policy - keep volumes
  reclaim_policy = "Retain"
  
  # Volume binding mode
  volume_binding_mode = "WaitForFirstConsumer"
  
  # Mount options
  mount_options = ["discard"]
}

# ConfigMap для StorageClass дополнительных параметров (опционально)
resource "kubernetes_config_map_v1" "storage_config" {
  metadata {
    name      = "storage-class-config"
    namespace = "kube-system"
  }
  
  data = {
    "default-parameters" = jsonencode({
      type      = "network-ssd"
      fsType    = "ext4"
      zone      = var.zone
    })
  }
}
