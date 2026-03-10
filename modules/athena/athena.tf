# NOTE: Workgroup isolates query execution and enforces output location in S3.
# Results are stored in a dedicated prefix to separate them from CloudTrail logs.
resource "aws_athena_workgroup" "this" {
  name = "${var.project_name}-cloudtrail-${var.environment}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false

    result_configuration {
      output_location = "s3://${var.s3_bucket_id}/athena-results/"

      # NOTE: Ensure to be the owner of the destination bucket.
      acl_configuration {
        s3_acl_option = "BUCKET_OWNER_FULL_CONTROL"
      }

      # NOTE: Encrypts query results with the same KMS key used for CloudTrail logs.
      encryption_configuration {
        encryption_option = "SSE_KMS"
        kms_key_arn       = var.kms_key_arn
      }
    }
  }
}
