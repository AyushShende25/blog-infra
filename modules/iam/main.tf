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

data "aws_iam_policy_document" "s3_media_policy" {
  statement {
    sid    = "AllowS3ObjectCRUD"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObjectAcl"
    ]
    resources = ["${var.s3_media_bucket_arn}/*"]
  }

  statement {
    sid       = "AllowS3BucketList"
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [var.s3_media_bucket_arn]
  }
}

resource "aws_iam_policy" "s3_media_policy" {
  name        = "${var.role_name}_s3_media_policy"
  path        = "/"
  description = "Allows EC2 instances to read, upload, and delete objects in the media S3 bucket"
  policy      = data.aws_iam_policy_document.s3_media_policy.json
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

resource "aws_iam_role_policy_attachment" "s3_media_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.s3_media_policy.arn
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
