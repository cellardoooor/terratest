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

  # Локальный путь до модуля
  source = "../../modules/vpc"

  # Передаём зону в модуль
  zone = var.zone

  # CIDR блок для подсети
  # В DEV обычно маленький диапазон
  cidr = var.dev_subnet_cidr
}


module "security" {
  source = "../../modules/security"

  network_id = module.vpc.network_id
  cidr       = var.dev_subnet_cidr
  allow_ssh_cidrs = var.allow_ssh_cidrs
}

module "compute" {

  # Путь до модуля VM
  source = "../../modules/compute"

  # Зона размещения ВМ
  zone = var.zone

  # Подсеть, в которой будут ВМ
  subnet_id = module.vpc.subnet_id

  vm_count = 1

  # Ресурсы ВМ
  cores  = 2
  memory = 2
  
  # Security groups
  security_group_ids = [module.security.vm_security_group_id]
  
  # Назначение публичного IP для test
  assign_public_ip = true
  
  metadata = {
    user-data = <<-EOF
      #cloud-config
      package_update: true

      runcmd:
        - apt-get install -y ansible git
        - ansible-pull \
            -U https://github.com/cellardoooor/platform-ansible.git \
            -i localhost, \
            playbook.yml
    EOF
  }
}

module "load_balancer" {
  source = "../../modules/load_balancer"

  name      = "test-lb"
  subnet_id = module.vpc.subnet_id
  targets   = module.compute.internal_ips
  depends_on = [module.compute]
}
