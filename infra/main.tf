module "s3_logs" {
  source = "../modules/s3-logs"

  environment    = var.environment
  project_name   = var.project_name
  aws_account_id = var.aws_account_id
}
