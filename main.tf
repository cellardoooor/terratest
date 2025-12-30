terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.120"
    }
  }

  required_version = ">= 1.3.0"
}

provider "yandex" {
    service_account_key_file = "key.json"
  cloud_id  = "b1gii3452auiela08s8k"
  folder_id = "b1gdnf54t05a11qn56sa"
  zone      = "ru-central1-a"
}

#resource "yandex_vpc_network" "test-vpc" {
 # name = "test-vpc"
#}