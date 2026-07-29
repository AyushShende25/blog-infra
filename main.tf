locals {
  common_tags = {
    Env     = var.environment
    Project = var.domain_name
  }
}

module "vpc" {
  source           = "./modules/vpc"
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  subnets = var.subnets
  tags = merge(
    local.common_tags,
    {
      Name = "inkspire_vpc"
    }
  )
}

module "security_groups" {
  source   = "./modules/security-groups"
  vpc_id   = module.vpc.vpc_id
  api_port = 80

  tags = local.common_tags
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
  tags = merge(local.common_tags,
    {
      Name = "inkspire-database"
    }
  )
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
  tags = merge(local.common_tags,
    {
      Name = "inkspire-redis"

    }
  )
}

module "iam" {
  source = "./modules/iam"

  role_name            = "inkspire_app_role"
  ssm_parameter_prefix = "inkspire/*"
  s3_media_bucket_arn  = module.s3_media.bucket_arn

  tags = local.common_tags
}

module "app_ecr" {
  source = "./modules/ecr"

  name                 = var.ecr_repository_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = true
  force_delete         = true

  tags = local.common_tags
}

module "api_launch_template" {
  source = "./modules/launch-template"

  template_name             = "inkspire-api-template"
  image_id                  = var.ami_id
  instance_type             = var.api_instance_type
  iam_instance_profile_name = module.iam.instance_profile_name
  vpc_security_group_ids    = [module.security_groups.api_sg_id]
  user_data_script          = "${path.module}/scripts/api-user-data.sh"

  tags = merge(local.common_tags,
    {
      Name = "inkspire-api"
    }
  )
}

module "worker_launch_template" {
  source = "./modules/launch-template"

  template_name             = "inkspire-worker-template"
  image_id                  = var.ami_id
  instance_type             = var.worker_instance_type
  iam_instance_profile_name = module.iam.instance_profile_name
  vpc_security_group_ids    = [module.security_groups.worker_sg_id]

  user_data_script = "${path.module}/scripts/worker-user-data.sh"

  tags = merge(local.common_tags,
    {
      Name = "inkspire-worker"
    }
  )
}

module "alb" {
  source = "./modules/alb"

  lb_name               = "inkspire-prod-alb"
  internal              = false
  public_subnet_ids     = values(module.vpc.public_subnet_ids)
  lb_security_group_ids = [module.security_groups.lb_sg_id]
  vpc_id                = module.vpc.vpc_id
  certificate_arn       = module.acm_alb.arn
  target_group_name     = "inkspire-api-tg"
  app_port              = 80
  health_check_path     = "/health"

  tags = local.common_tags
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
  tags = merge(local.common_tags,
    {
      Role = "api"
    }
  )
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
  tags = merge(local.common_tags,
    {
      Role = "worker"
    }
  )
}

module "s3_media" {
  source = "./modules/s3"

  bucket_name = "${var.domain_name}-media-uploads"
  client_url  = "https://${var.domain_name}"
  enable_cors = true

  tags = merge(local.common_tags,
    {
      Type = "media-uploads"
    }
  )
}

module "s3_react" {
  source = "./modules/s3"

  bucket_name = var.domain_name
  enable_cors = false

  tags = merge(local.common_tags,
    {
      Type = "frontend-static"
    }
  )
}

module "cloudfront_react" {
  source = "./modules/cloudfront"

  name                           = "inkspire-react-cdn"
  s3_bucket_id                   = module.s3_react.bucket_id
  s3_bucket_arn                  = module.s3_react.bucket_arn
  s3_bucket_regional_domain_name = module.s3_react.bucket_regional_domain_name
  domain_aliases                 = [var.domain_name]
  acm_certificate_arn            = module.acm_cloudfront.arn
  is_spa                         = true

  tags = local.common_tags
}

module "cloudfront_media" {
  source = "./modules/cloudfront"

  name                           = "inkspire-media-cdn"
  s3_bucket_id                   = module.s3_media.bucket_id
  s3_bucket_arn                  = module.s3_media.bucket_arn
  s3_bucket_regional_domain_name = module.s3_media.bucket_regional_domain_name
  domain_aliases                 = ["media.${var.domain_name}"]
  acm_certificate_arn            = module.acm_cloudfront.arn
  is_spa                         = false

  tags = local.common_tags
}

data "aws_route53_zone" "main" {
  name         = "fullstackprojects.dev"
  private_zone = false
}

module "acm_cloudfront" {
  source = "./modules/acm"

  providers = {
    aws = aws.us_east_1
  }

  domain_name               = var.domain_name
  subject_alternative_names = ["media.${var.domain_name}"]
  hosted_zone_id            = data.aws_route53_zone.main.zone_id

  tags = local.common_tags
}

module "acm_alb" {
  source = "./modules/acm"

  domain_name    = "api.${var.domain_name}"
  hosted_zone_id = data.aws_route53_zone.main.zone_id

  tags = local.common_tags
}

module "dns_react" {
  source = "./modules/route53"

  hosted_zone_id  = data.aws_route53_zone.main.zone_id
  domain_name     = var.domain_name
  target_dns_name = module.cloudfront_react.domain_name
  target_zone_id  = module.cloudfront_react.hosted_zone_id
}

module "dns_media" {
  source = "./modules/route53"

  hosted_zone_id  = data.aws_route53_zone.main.zone_id
  domain_name     = "media.${var.domain_name}"
  target_dns_name = module.cloudfront_media.domain_name
  target_zone_id  = module.cloudfront_media.hosted_zone_id
}

module "dns_api" {
  source = "./modules/route53"

  hosted_zone_id  = data.aws_route53_zone.main.zone_id
  domain_name     = "api.${var.domain_name}"
  target_dns_name = module.alb.alb_dns_name
  target_zone_id  = module.alb.alb_zone_id
}

module "ssm" {
  source = "./modules/parameter-store"

  env        = "production"
  client_url = "https://${var.domain_name}"

  db_user     = var.db_username
  db_password = var.db_password
  db_endpoint = module.rds.endpoint
  db_name     = module.rds.db_name

  redis_endpoint = module.redis.primary_endpoint
  redis_password = var.redis_password

  media_bucket_name   = module.s3_media.bucket_id
  media_bucket_region = var.aws_region
  media_bucket_domain = module.s3_media.bucket_regional_domain_name

  tags = local.common_tags
}
