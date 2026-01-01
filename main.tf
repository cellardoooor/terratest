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
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

module "vpc" {
  source = "./modules/vpc"
}

module "compute" {
  source = "./modules/compute"
  vpc_id = module.vpc.network_id
  zone   = var.zone
}
module "load_balancer" {
  source = "./modules/load_balancer"
  web_server_ips = [
    module.compute.web_server1_ip,
    module.compute.web_server2_ip
  ]
  vpc_id    = module.vpc.network_id
  folder_id = var.folder_id
  zone      = var.zone
}

