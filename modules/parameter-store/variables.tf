variable "client_url" {
  type        = string
  description = "Frontend client URL (e.g., https://inkspire.fullstackprojects.dev)"
}

variable "env" {
  type        = string
  description = "Deployment environment (development, production)"
  default     = "production"
}

variable "db_user" {
  type        = string
  description = "Master username for PostgreSQL database"
}

variable "db_password" {
  type        = string
  description = "Master password for PostgreSQL database"
  sensitive   = true
}

variable "db_endpoint" {
  type        = string
  description = "PostgreSQL endpoint from RDS module (e.g. host:port or hostname)"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "redis_endpoint" {
  type        = string
  description = "Redis primary endpoint hostname or IP"
}

variable "redis_password" {
  type        = string
  description = "Redis auth password (if AUTH enabled)"
  default     = ""
  sensitive   = true
}

variable "media_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for media uploads"
}

variable "media_bucket_region" {
  type        = string
  description = "AWS Region where the S3 bucket is hosted"
  default     = "ap-south-1"
}

variable "media_bucket_domain" {
  type        = string
  description = "custom CDN domain for S3 bucket"
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the SSM parameters"
  default     = {}
}
