data "aws_iam_policy_document" "cloudtrail" {
  statement {
    sid    = "EnableRootAccess"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudTrail"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazon.com"]
    }
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key" "cloudtrail" {
  description             = "KMS key for CloudTrail logs - ${var.environment}"
  deletion_window_in_days = 20
  enable_key_rotation     = true

  policy = data.aws_iam_policy_document.cloudtrail.json

  tags = merge(var.tags, {
    Environment = var.environment
  })
}

resource "aws_kms_alias" "cloudtrail" {
  name          = "alias/${var.project_name}-cloudtrail-${var.environment}"
  target_key_id = aws_kms_key.cloudtrail.key_id
}

resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${var.project_name}-cloudtrail-logs-${var.environment}"

  tags = merge(var.tags, {
    Environment = var.environment
  })
}
