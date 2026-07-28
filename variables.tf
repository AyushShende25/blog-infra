variable "aws_region" {
  description = "The AWS region to create resources in"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_cidr" {
  type        = string
  description = "The IPv4 CIDR block for the VPC."
}

variable "domain_name" {
  type = string
}

variable "subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
    type              = string
  }))
  description = "Map of subnets to create, key = subnet name"
}

# DATABASE - RDS

variable "db_subnet_group_name" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "db_identifier" {
  type = string
}
variable "psql_version" {
  type = string
}
variable "db_instance_class" {
  type = string
}

variable "db_allocated_storage" {
  type = number
}

# ELASTICACHE
variable "redis_replication_group_name" {
  type        = string
  description = "Unique identifier for the replication group"
}

variable "redis_node_type" {
  type        = string
  description = "Instance type for Redis nodes"
}

variable "redis_subnet_group_name" {
  type        = string
  description = "Name for the ElastiCache subnet group"
}

variable "redis_engine_version" {
  type        = string
  description = "Redis engine version"
}

variable "num_cache_clusters" {
  type        = number
  description = "Number of replicas for redis"
}

variable "redis_password" {
  type        = string
  description = "Password (AUTH token) for Redis client authentication"
  sensitive   = true
}

# ECR

variable "ecr_repository_name" {
  type        = string
  description = "Name of the ECR repository"
}

variable "image_tag_mutability" {
  type        = string
  description = "The tag mutability setting for the repository. Must be MUTABLE or IMMUTABLE"
  default     = "IMMUTABLE"
}

# Launch-Template
variable "ami_id" {
  type        = string
  description = "The AMI ID to use for the instance"
}

variable "api_instance_type" {
  type    = string
  default = "t3.small"
}

variable "worker_instance_type" {
  type    = string
  default = "t3.small"
}
