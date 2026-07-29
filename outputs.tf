output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

# output "igw_id" {
#   description = "The ID of the Internet Gateway"
#   value       = module.vpc.igw_id
# }

# output "subnet_ids" {
#   description = "Map of subnet names to subnet IDs"
#   value       = module.vpc.subnet_ids
# }

# output "nat_gateway_ids" {
#   description = "Map of public subnet names to NAT Gateway IDs"
#   value       = module.vpc.nat_gateway_ids
# }

output "db_endpoint" {
  description = "Database endpoint"
  value       = module.rds.endpoint
}

output "redis_endpoint" {
  description = "Redis primary endpoint"
  value       = module.redis.primary_endpoint
}

output "alb_dns_name" {
  description = "DNS name of the ALB to point domain/Route53 records to"
  value       = module.alb.alb_dns_name
}

output "ecr_repository_url" {
  description = "The URL of the repository"
  value       = module.app_ecr.repository_url
}
