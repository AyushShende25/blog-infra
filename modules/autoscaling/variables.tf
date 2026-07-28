variable "name" {
  type        = string
  description = "Name prefix for the Auto Scaling Group"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances"
  default     = 1
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances"
  default     = 3
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances"
  default     = 1
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of private subnet IDs for Multi-AZ instance deployment"
}

variable "launch_template_id" {
  type        = string
  description = "ID of the Launch Template to use"
}

variable "launch_template_version" {
  type        = string
  description = "Version of Launch Template ($Latest or $Default)"
  default     = "$Latest"
}

variable "health_check_type" {
  type        = string
  description = "Health check type: EC2 or ELB (Use ELB for API behind ALB)"
  default     = "EC2"
}

variable "health_check_grace_period" {
  type        = number
  description = "Time in seconds before checking health after instance launch"
  default     = 300
}

variable "target_group_arns" {
  type        = list(string)
  description = "List of ALB Target Group ARNs (Optional for worker, required for API)"
  default     = []
}

variable "min_healthy_percentage" {
  type        = number
  description = "Minimum percent of healthy instances during refresh"
  default     = 50
}

variable "max_healthy_percentage" {
  type        = number
  description = "Maximum percent of healthy instances during refresh"
  default     = 200
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to resources"
  default     = {}
}
