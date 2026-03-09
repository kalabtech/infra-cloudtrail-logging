# tflint-ignore: terraform_unused_declarations
variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = null
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "Infra-Cloudtrail-Logging"
}

# tflint-ignore: terraform_unused_declarations
variable "environment" {
  description = "Environment name (dev/prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS Region for provider"
  type        = string
  default     = "eu-west-1"
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  sensitive   = true
}
