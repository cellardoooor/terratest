terraform {
  backend "s3" {
    bucket                      = "tf-state-k8s-platform"
    key                         = "platform/terraform.tfstate"
    region                      = "ru-central1"
    endpoint                    = "https://storage.yandexcloud.net"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
  }
}
