variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "s3_bucket_id" {
  description = "S3 bucket ID where CloudTrail logs are stored"
  type        = string
}
