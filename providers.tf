provider "yandex" {
  service_account_key_file = var.sa_key_path
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

provider "kubernetes" {
  host                   = module.kubernetes_cluster.cluster_endpoint
  cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_certificate
  token                  = var.k8s_token
}

provider "helm" {
  kubernetes {
    host                   = module.kubernetes_cluster.cluster_endpoint
    cluster_ca_certificate = module.kubernetes_cluster.cluster_ca_certificate
    token                  = var.k8s_token
  }
}
