resource "aws_launch_template" "template" {
  name                   = var.template_name
  image_id               = var.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids
  update_default_version = var.update_default_version

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  tag_specifications {
    resource_type = "instance"
    tags          = var.tags
  }

  user_data = var.user_data_script != null ? filebase64(var.user_data_script) : null

  tags = var.tags
}
