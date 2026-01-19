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
  cidr = var.cidr

  network_name = "dev-lb-network"
}

module "load_balancer" {
  source = "../../modules/load_balancer"

  name      = "dev-lb"
  subnet_id = module.vpc.subnet_id
  targets   = module.instance_group.instance_ips
}

module "security" {
  source = "../../modules/security"

  # Передаём то что нужно security модулю
  network_id = module.vpc.network_id
  cidr       = var.cidr

  # Опционально: список IP для SSH
  allow_ssh_cidrs = var.allow_ssh_cidrs
}

module "instance_group" {
  source = "../../modules/instance_group"

  name               = "web-group"
  size               = 2 # вместо vm_count
  zones              = [var.zone]
  subnet_ids         = [module.vpc.subnet_id]
  network_id         = module.vpc.network_id
  security_group_ids = [module.security.vm_security_group_id]
  service_account_id = var.service_account_id

  cores     = 2
  memory    = 2
  disk_size = 10

  target_group_name = "web-targets"
  health_check_path = "/healthz"
}
