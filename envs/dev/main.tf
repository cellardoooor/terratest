# Модуль Network
module "network" {
  source = "../../modules/network"

  network_name        = var.network_name
  zone                = var.zone
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# Модуль Security Groups
module "security_groups" {
  source = "../../modules/security_groups"

  network_name        = var.network_name
  network_id          = module.network.vpc_id
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
}

# Модуль Kubernetes Cluster
module "kubernetes_cluster" {
  source = "../../modules/kubernetes_cluster"

  cluster_name              = var.cluster_name
  network_id                = module.network.vpc_id
  zone                      = var.zone
  private_subnet_id         = module.network.private_subnet_id
  k8s_version               = var.k8s_version
  worker_count              = var.worker_count
  worker_cores              = var.worker_cores
  worker_memory             = var.worker_memory
  service_account_id        = var.service_account_id
  master_security_group_ids = []
  node_security_group_ids   = [module.security_groups.k8s_nodes_sg_id]
  ssh_public_key_path       = var.ssh_public_key_path
  ssh_user                  = var.ssh_user
}

# Модуль Ingress (Load Balancer для Ingress Controller)
module "ingress" {
  source = "../../modules/ingress"

  network_name       = var.network_name
  public_subnet_id   = module.network.public_subnet_id
  private_subnet_id  = module.network.private_subnet_id
  public_subnet_cidr = var.public_subnet_cidr
  ingress_namespace  = var.ingress_namespace
}
