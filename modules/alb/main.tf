resource "aws_lb_target_group" "api_tg" {
  name        = var.target_group_name
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    path                = var.health_check_path
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    { Name = var.target_group_name }
  )
}

resource "aws_lb" "alb" {
  name                       = var.lb_name
  internal                   = var.internal
  load_balancer_type         = "application"
  security_groups            = var.lb_security_group_ids
  subnets                    = var.public_subnet_ids
  enable_deletion_protection = false

  tags = var.tags
}


resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api_tg.arn
  }
}
