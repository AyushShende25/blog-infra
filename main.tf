module "vpc" {
  source           = "./modules/vpc"
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  subnets = var.subnets
  tags = {
    Name    = "inkspire_vpc"
    Env     = "production"
    Website = var.domain_name
  }
}
