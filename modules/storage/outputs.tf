output "storage_class_name" {
  description = "Name of the StorageClass"
  value       = kubernetes_storage_class_v1.this.metadata[0].name
}

output "storage_class_provisioner" {
  description = "Provisioner of the StorageClass"
  value       = kubernetes_storage_class_v1.this.provisioner
}
