# tflint-ignore: terraform_unused_declarations
variable "aws_profile" {
  description = "AWS CLI profile to use for authentication"
  type        = string
  default     = null
}

variable "project" {
  type    = string
  default = "Infra-Cloudtrail-Logging"
}

variable "environment" {
  type = string
}

variable "aws_region" {
  description = "AWS Region for provider"
  type        = string
  default     = "eu-west-1"
}

