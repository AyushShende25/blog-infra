variable "template_name" {
  type        = string
  description = "Name of the Launch Template"
}

variable "image_id" {
  type        = string
  description = "The AMI ID to use for the instance"
}

variable "instance_type" {
  type        = string
  description = "The type of instance to launch (e.g., t3.micro)"
  default     = "t3.micro"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "Name of the IAM Instance Profile to attach"
  default     = null
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach to the instance"
  default     = []
}

variable "user_data_script" {
  type        = string
  description = "Path to the user data script file relative to the calling path, or raw bash content"
  default     = null
}

variable "update_default_version" {
  type        = bool
  description = "Whether to update Default Version of Launch Template each time a new version is created"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to assign to the Launch Template resource itself and the instances created from it"
  default     = {}
}
