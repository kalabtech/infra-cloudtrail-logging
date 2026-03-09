# NOTE: Call to S3 module to create bucket and kms with cloudtrail service policy access
module "s3_logs" {
  source = "../modules/s3-logs"

  environment    = var.environment
  project_name   = var.project_name
  aws_account_id = var.aws_account_id
}

# NOTE: Call cloutrail module to crate a trail
module "cloudtrail" {
  source = "../modules/cloudtrail"

  environment  = var.environment
  project_name = var.project_name
  s3_bucket_id = module.s3_logs.bucket_id
  kms_key_arn  = module.s3_logs.kms_key_arn
}
