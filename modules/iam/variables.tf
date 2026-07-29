variable "role_name" {
  type        = string
  description = "Name of the IAM role for instances"
  default     = "inkspire_instance_role"
}

variable "ssm_parameter_prefix" {
  type        = string
  description = "SSM Parameter Store path prefix to allow access to"
  default     = "inkspire/*"
}

variable "s3_media_bucket_arn" {
  type        = string
  description = "ARN of the media-uploads S3 Bucket"
}


variable "tags" {
  type        = map(string)
  description = "A map of tags to assign to the resource."
  default     = {}
}
