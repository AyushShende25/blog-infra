output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB to point domain/Route53 records to"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "Canonical Hosted Zone ID of the ALB (for Route53 Alias records)"
  value       = aws_lb.alb.zone_id
}

output "target_group_arn" {
  description = "ARN of the API Target Group (pass to Auto Scaling Group)"
  value       = aws_lb_target_group.api_tg.arn
}
