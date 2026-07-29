module "vpc" {
  source           = "./modules/vpc"
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  subnets = var.subnets
  tags = {
    Name    = "inkspire_vpc"
    Env     = "production"
    Project = var.domain_name
  }
}

module "security_groups" {
  source   = "./modules/security-groups"
  vpc_id   = module.vpc.vpc_id
  api_port = 80

  tags = {
    Name    = "inkspire_vpc"
    Env     = "production"
    Project = var.domain_name
  }
}

module "rds" {
  source                  = "./modules/rds"
  db_identifier           = var.db_identifier
  engine_version          = var.psql_version
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
    Project = var.domain_name
  }
}

module "redis" {
  source                  = "./modules/elasticache"
  replication_group_id    = var.redis_replication_group_name
  node_type               = var.redis_node_type
  redis_subnet_group_name = var.redis_subnet_group_name
  security_group_ids      = [module.security_groups.redis_sg_id]
  subnet_ids              = values(module.vpc.db_subnet_ids)
  engine_version          = var.redis_engine_version
  password                = var.redis_password
  num_cache_clusters      = var.num_cache_clusters
  tags = {
    Name    = "inkspire-redis"
    Env     = "production"
    Project = var.domain_name
  }
}

module "iam" {
  source = "./modules/iam"

  role_name            = "inkspire_app_role"
  ssm_parameter_prefix = "inkspire/*"

  tags = {
    Env     = "production"
    Project = var.domain_name
  }
}

module "app_ecr" {
  source = "./modules/ecr"

  name                 = var.ecr_repository_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = true
  force_delete         = true

  tags = {
    Env     = "production"
    Project = var.domain_name
  }
}

module "api_launch_template" {
  source = "./modules/launch-template"

  template_name             = "inkspire-api-template"
  image_id                  = var.ami_id
  instance_type             = var.api_instance_type
  iam_instance_profile_name = module.iam.instance_profile_name
  vpc_security_group_ids    = [module.security_groups.api_sg_id]
  user_data_script          = "${path.module}/scripts/api-user-data.sh"

  tags = {
    Name    = "inkspire-api"
    Env     = "production"
    Project = var.domain_name
  }
}

module "worker_launch_template" {
  source = "./modules/launch-template"

  template_name             = "inkspire-worker-template"
  image_id                  = var.ami_id
  instance_type             = var.worker_instance_type
  iam_instance_profile_name = module.iam.instance_profile_name
  vpc_security_group_ids    = [module.security_groups.worker_sg_id]

  user_data_script = "${path.module}/scripts/worker-user-data.sh"

  tags = {
    Name    = "inkspire-worker"
    Env     = "production"
    Project = var.domain_name
  }
}

module "alb" {
  source = "./modules/alb"

  lb_name               = "inkspire-prod-alb"
  internal              = false
  public_subnet_ids     = values(module.vpc.public_subnet_ids)
  lb_security_group_ids = [module.security_groups.lb_sg_id]
  vpc_id                = module.vpc.vpc_id

  target_group_name = "inkspire-api-tg"
  app_port          = 80
  health_check_path = "/health"

  tags = {
    Env     = "production"
    Project = var.domain_name
  }
}

module "api_asg" {
  source = "./modules/autoscaling"

  name                   = "inkspire-api-asg"
  min_size               = 2
  max_size               = 5
  desired_capacity       = 2
  subnet_ids             = values(module.vpc.app_subnet_ids)
  launch_template_id     = module.api_launch_template.id
  health_check_type      = "ELB"
  target_group_arns      = [module.alb.target_group_arn]
  min_healthy_percentage = 50
  max_healthy_percentage = 200
  tags = {
    Env     = "production"
    Role    = "api"
    Project = var.domain_name
  }
}

module "worker_asg" {
  source = "./modules/autoscaling"

  name                   = "inkspire-worker-asg"
  min_size               = 1
  max_size               = 3
  desired_capacity       = 1
  subnet_ids             = values(module.vpc.app_subnet_ids)
  launch_template_id     = module.worker_launch_template.id
  health_check_type      = "EC2"
  target_group_arns      = []
  min_healthy_percentage = 100
  max_healthy_percentage = 200
  tags = {
    Env     = "production"
    Role    = "worker"
    Project = var.domain_name
  }
}

module "s3_media" {
  source = "./modules/s3"

  bucket_name                 = "${var.domain_name}-media-uploads"
  cloudfront_distribution_arn = module.cloudfront_media.arn
  client_url                  = "https://${var.domain_name}"
  enable_cors                 = true

  tags = {
    Type    = "media-uploads"
    Env     = "production"
    Project = var.domain_name
  }
}

module "s3_react" {
  source = "./modules/s3"

  bucket_name                 = var.domain_name
  cloudfront_distribution_arn = module.cloudfront_react.arn
  enable_cors                 = false

  tags = {
    Type    = "frontend-static"
    Env     = "production"
    Project = var.domain_name
  }
}
