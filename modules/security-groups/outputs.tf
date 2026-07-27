output "lb_sg_id" {
  value = aws_security_group.lb.id
}

output "api_sg_id" {
  value = aws_security_group.app_api.id
}

output "worker_sg_id" {
  value = aws_security_group.app_worker.id
}

output "db_sg_id" {
  value = aws_security_group.db.id
}

output "redis_sg_id" {
  value = aws_security_group.redis.id
}
