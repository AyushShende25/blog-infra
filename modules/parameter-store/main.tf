locals {
  name_prefix = "/inkspire/prod"

  string_parameters = {
    "NODE_ENV"             = "production"
    "PORT"                 = "4000"
    "CLIENT_URL"           = var.client_url
    "BUCKET_NAME"          = var.media_bucket_name
    "BUCKET_REGION"        = var.media_bucket_region
    "BUCKET_CUSTOM_DOMAIN" = var.media_bucket_domain
  }

  secure_parameters = {
    "DATABASE_URL" = "postgresql://${var.db_user}:${var.db_password}@${var.db_endpoint}/${var.db_name}?sslmode=no-verify"
    "REDIS_URL"    = "rediss://:${var.redis_password}@${var.redis_endpoint}:6379"
  }
}


resource "aws_ssm_parameter" "strings" {
  for_each = local.string_parameters

  name  = "${local.name_prefix}/${each.key}"
  type  = "String"
  value = each.value

  tags = var.tags
}

resource "aws_ssm_parameter" "secures" {
  for_each = local.secure_parameters

  name  = "${local.name_prefix}/${each.key}"
  type  = "SecureString"
  value = each.value

  tags = var.tags
}

