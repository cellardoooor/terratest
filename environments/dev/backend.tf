terraform {
  backend "s3" {
    bucket = "tf-state-dev-uuuu"
    key    = "dev/terraform.tfstate"
    region = "ru-central1"

    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }

    skip_region_validation       = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
  }
}
