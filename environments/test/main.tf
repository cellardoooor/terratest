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
  cidr = var.cidr
}

module "security_groups" {
  source     = "../../modules/security"
  network_id = module.vpc.network_id
  cidr       = var.cidr
}

module "compute" {

  # Путь до модуля VM
  source = "../../modules/compute"

  # Зона размещения ВМ
  zone = var.zone

  # Подсеть, в которой будут ВМ
  # module.network.subnet_id —
  # это output из модуля network
  subnet_id = module.vpc.subnet_id

  vm_count = 1

  # Ресурсы ВМ
  cores              = 2
  memory             = 2
  assign_public_ip   = true
  security_group_ids = [module.security_groups.web_open_id]
  metadata = {
  user-data = <<-EOF
    #cloud-config
    package_update: true

    runcmd:
      - echo "=== START ==="
      - apt-get install -y ansible git
      - cd /tmp
      - git clone https://github.com/cellardoooor/ansible_test
      - cd ansible_test
      - ansible-playbook -i localhost, playbook.yml
      - echo "=== DONE ==="
  EOF
}
}




