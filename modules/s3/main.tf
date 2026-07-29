resource "aws_s3_bucket" "s3" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket     = aws_s3_bucket.s3.id
  policy     = data.aws_iam_policy_document.allow_access_from_cloudfront.json
  depends_on = [aws_s3_bucket_public_access_block.block]
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.s3.arn}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [var.cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "cors" {
  count  = var.enable_cors ? 1 : 0
  bucket = aws_s3_bucket.s3.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = [var.client_url]
    expose_headers  = ["ETag", "x-amz-server-side-encryption", "x-amz-request-id", "x-amz-id-2"]
    max_age_seconds = 3000
  }

}
