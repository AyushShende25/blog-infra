output "role_arn" {
  description = "ARN of the instance IAM role"
  value       = aws_iam_role.instance.arn
}

output "role_name" {
  description = "Name of the instance IAM role"
  value       = aws_iam_role.instance.name
}

output "instance_profile_name" {
  description = "Name of the IAM Instance Profile to attach to EC2"
  value       = aws_iam_instance_profile.instance.name
}

output "instance_profile_arn" {
  description = "ARN of the IAM Instance Profile"
  value       = aws_iam_instance_profile.instance.arn
}
