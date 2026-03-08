variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "aws_account_id" {
  description = "AWS Account ID for bucket policy"
  type        = string
  sensitive   = true
}
