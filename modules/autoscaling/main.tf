resource "aws_autoscaling_group" "asg" {
  name_prefix               = "${var.name}-"
  vpc_zone_identifier       = var.subnet_ids
  desired_capacity          = var.desired_capacity
  max_size                  = var.max_size
  min_size                  = var.min_size
  health_check_grace_period = var.health_check_grace_period
  health_check_type         = var.health_check_type
  target_group_arns         = var.target_group_arns

  launch_template {
    id      = var.launch_template_id
    version = var.launch_template_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = var.min_healthy_percentage
      max_healthy_percentage = var.max_healthy_percentage
      skip_matching          = false
    }
  }

  dynamic "tag" {
    for_each = merge(var.tags, { Name = var.name })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  # To prevent Terraform from scaling your instances when it changes other aspects of your configuration, use a lifecycle argument to ignore changes to the desired capacity and target groups
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity, target_group_arns]
  }

}
