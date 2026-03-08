output "bucket_arn" {
  description = "ARN of the CloudTrail S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "bucket_id" {
  description = "ID of the CloudTrail S3 bucket"
  value       = aws_s3_bucket.this.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key"
  value       = aws_kms_key.this.arn
}

output "kms_key_id" {
  description = "ID of the KMS key"
  value       = aws_kms_key.this.id
}
