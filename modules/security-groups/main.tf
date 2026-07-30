resource "aws_security_group" "lb" {
  name        = "lb"
  description = "Allow HTTP traffic from Internet"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { Name = "lb" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "lb_https_ipv4" {
  security_group_id = aws_security_group.lb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "lb_http_ipv4" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "lb_egress_ipv4" {
  security_group_id = aws_security_group.lb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_security_group" "app_api" {
  name        = "app-api"
  description = "Allow HTTP traffic exclusively from Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    { Name = "app-api" }
  )
}

resource "aws_vpc_security_group_ingress_rule" "api_from_lb" {
  security_group_id            = aws_security_group.app_api.id
  referenced_security_group_id = aws_security_group.lb.id
  from_port                    = var.api_port
  to_port                      = var.api_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "api_egress_ipv4" {
  security_group_id = aws_security_group.app_api.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_security_group" "app_worker" {
  name        = "app-worker"
  description = "Background worker instances"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "app-worker" })
}

resource "aws_vpc_security_group_egress_rule" "worker_egress_ipv4" {
  security_group_id = aws_security_group.app_worker.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


resource "aws_security_group" "db" {
  name        = "db"
  description = "Database access from API and Worker"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "db" })
}

resource "aws_vpc_security_group_ingress_rule" "db_from_api" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app_api.id
  from_port                    = var.postgres_port
  to_port                      = var.postgres_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "db_from_worker" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app_worker.id
  from_port                    = var.postgres_port
  to_port                      = var.postgres_port
  ip_protocol                  = "tcp"
}

resource "aws_security_group" "redis" {
  name        = "redis"
  description = "Redis access from API and Worker"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "redis" })
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_api" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.app_api.id
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "redis_from_worker" {
  security_group_id            = aws_security_group.redis.id
  referenced_security_group_id = aws_security_group.app_worker.id
  from_port                    = var.redis_port
  to_port                      = var.redis_port
  ip_protocol                  = "tcp"
}
