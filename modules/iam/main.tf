data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "instance_role"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.instance_assume_role_policy.json

  tags = var.tags
}

data "aws_iam_policy_document" "parameter_store" {
  statement {
    sid    = "AllowSSMParameterRead"
    effect = "Allow"
    actions = [
      "ssm:GetParameterHistory",
      "ssm:GetParametersByPath",
      "ssm:GetParameters",
      "ssm:GetParameter"
    ]
    resources = [
      "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:parameter/${var.ssm_parameter_prefix}"
    ]
  }

  statement {
    sid       = "AllowSSMDescribeParameters"
    effect    = "Allow"
    actions   = ["ssm:DescribeParameters"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "parameter_store" {
  name        = "${var.role_name}_ssm_parameter_store_policy"
  path        = "/"
  description = "Allows reading SSM parameters under ${var.ssm_parameter_prefix}"
  policy      = data.aws_iam_policy_document.parameter_store.json
}

data "aws_iam_policy" "ecr" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cw" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "parameter_store" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.parameter_store.arn
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.instance.name
  policy_arn = data.aws_iam_policy.ecr.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_role_policy_attachment" "cw" {
  role       = aws_iam_role.instance.name
  policy_arn = data.aws_iam_policy.cw.arn
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.role_name}_profile"
  role = aws_iam_role.instance.name
  tags = var.tags
}
