variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 bucket ID where CloudTrail logs will be stored"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used to encrypt CloudTrail logs"
  type        = string
}
