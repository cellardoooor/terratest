provider "yandex" {
  service_account_key_file = var.sa_key_path
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

# Kubernetes provider будет настроен динамически после создания кластера
# Это можно сделать через terraform output или в CI/CD pipeline
# Для развертывания:
# terraform output -raw cluster_endpoint > endpoint.txt
# terraform output -raw cluster_ca_certificate > ca_cert.txt
# terraform output -raw cluster_token > token.txt
# И настроить kubernetes provider в envs/dev/main.tf
