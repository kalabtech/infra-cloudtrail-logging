---
name: template_security
about: Security Review / Hardening
title: "[SECURITY]: Action"
labels: security
assignees: kalabtech

---

Title Ex: [SECURITY]: Implement S3 Bucket Policy for Least Privilege
---
## Risk Analysis
- **Affected Resource:**
- **Identified Risk:** (e.g., Public S3 Bucket, Port 22 open to the world).

## Mitigation Actions
- [ ] Apply Least Privilege Policy (IAM).
- [ ] Enable Encryption at Rest (KMS).
- [ ] Enable Audit Logging (CloudTrail/AWS Config).

## Expected Outcome (Ex: encryption KMS/S3 )
- AWS CLI command get-bucket-encryption confirms AES256 or aws:kms is active.
- Objects uploaded without encryption headers are automatically encrypted by the bucket policy.
