
module "vpc" {
  source = "./modules/vpc"
  zone   = var.zone
}

module "compute" {
  source    = "./modules/compute"
  zone      = var.zone
  subnet_id = module.vpc.subnet_id
}

module "load_balancer" {
  source    = "./modules/load_balancer"
  subnet_id = module.vpc.subnet_id
  web_server_ips = [
    module.compute.web_server1_ip,
    module.compute.web_server2_ip
  ]
}