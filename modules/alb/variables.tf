variable "lb_name" {
  type        = string
  description = "Name of the Application Load Balancer"
  default     = "inkspire-alb"
}

variable "internal" {
  type        = bool
  description = "Whether the ALB is internal or internet-facing"
  default     = false
}

variable "lb_security_group_ids" {
  type        = list(string)
  description = "List of Security Group IDs for the ALB"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of Public Subnet IDs where ALB will reside"
}

variable "target_group_name" {
  type        = string
  description = "Name of the default target group"
  default     = "inkspire-api-tg"
}

variable "app_port" {
  type        = number
  description = "Port where backend applications listen (e.g., 4000 or 80)"
  default     = 80
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where Target Group resides"
}

variable "health_check_path" {
  type        = string
  description = "HTTP endpoint for ALB health checks"
  default     = "/health" # Ensure your app responds 200 OK here
}

variable "s3_logs_bucket_id" {
  type        = string
  description = "S3 bucket ID for ALB access logs"
  default     = null
}

variable "certificate_arn" {
  type        = string
  description = "ARN of the ACM certificate created for the ALB"
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to resources"
  default     = {}
}
