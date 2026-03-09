#trivy:ignore:AVD-AWS-0014 - Single region deployment, multi-region disabled intentionally to reduce costs
resource "aws_cloudtrail" "this" {
  name                          = "${var.project_name}-trail-${var.environment}"
  s3_bucket_name                = var.s3_bucket_id
  kms_key_id                    = var.kms_key_arn
  include_global_service_events = true
  is_multi_region_trail         = false
  enable_log_file_validation    = true
}
