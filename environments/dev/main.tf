terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.177.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "yandex" {
  service_account_key_file = var.sa_key_path
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}

module "vpc" {
  source = "../../modules/vpc"
  
  zone = var.zone
  cidr = "10.10.0.0/24"
  
  network_name = "dev-lb-network"
}

module "compute" {
  source = "../../modules/compute"
  
  zone      = var.zone
  subnet_id = module.vpc.subnet_id
  
  # VM получают ТОЛЬКО security group для инстансов
  security_group_ids = [module.vpc.vm_security_group_id]
  
  vm_count = 2
  cores    = 2
  memory   = 2
}

module "load_balancer" {
  source = "../../modules/load_balancer"
  
  subnet_id = module.vpc.subnet_id
  targets   = module.compute.internal_ips
  
  # Балансировщик получает СВОЮ security group
  security_group_ids = [module.vpc.load_balancer_security_group_id]
}