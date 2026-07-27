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

module "security_groups" {
  source   = "./modules/security-groups"
  vpc_id   = module.vpc.vpc_id
  api_port = 80

  tags = {
    Name    = "inkspire_vpc"
    Env     = "production"
    Website = var.domain_name
  }
}

module "rds" {
  source                  = "./modules/rds"
  db_identifier           = "inkspire-psql"
  engine_version          = "18.3"
  db_subnet_group_name    = var.db_subnet_group_name
  subnet_ids              = values(module.vpc.db_subnet_ids)
  db_name                 = var.db_name
  allocated_storage       = var.db_allocated_storage
  instance_class          = var.db_instance_class
  username                = var.db_username
  password                = var.db_password
  backup_retention_period = 1
  skip_final_snapshot     = true
  vpc_security_group_ids  = [module.security_groups.db_sg_id]
  tags = {
    Name    = "inkspire-database"
    Env     = "production"
    Website = var.domain_name
  }
}
