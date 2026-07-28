output "id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.template.id
}

output "arn" {
  description = "The ARN of the Launch Template"
  value       = aws_launch_template.template.arn
}

output "latest_version" {
  description = "The latest version of the Launch Template"
  value       = aws_launch_template.template.latest_version
}
