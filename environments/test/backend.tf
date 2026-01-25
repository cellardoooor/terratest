terraform {
  backend "s3" {
    bucket = "tf-state-test-uuuu"
    key    = "test/terraform.tfstate"
    region = "ru-central1"

    #s3_force_path_style = true
    endpoint = "https://storage.yandexcloud.net"

    skip_region_validation      = true
    skip_credentials_validation = true
    #skip_requesting_account_id  = true
  }
}
