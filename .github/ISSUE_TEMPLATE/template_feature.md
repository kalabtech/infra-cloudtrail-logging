---
name: template_feature
about: Standard template for creating infrastructure using Terraform.
title: "[SERVICIO]: Action"
labels: documentation, enhancement
assignees: kalabtech

---

Title Ex: [S3]: Setup Remote Backend and DynamoDB Lock
---

## Description
The goal is to move the Terraform state file from my local machine to a secure, remote location in AWS. This is a best practice for security and collaboration. I will use Amazon S3 for storage and DynamoDB for state locking to prevent concurrent executions.

## Technical Checklist
- [ ] Define the resource in Terraform (`main.tf`).
- [ ] Configure variables and outputs.
- [ ] Run `terraform plan` and verify changes.
- [ ] Apply changes with `terraform apply`.

## Security Check
- [ ] Have I applied the Principle of Least Privilege (IAM)?
- [ ] Are the resources private by default?
- [ ] Have I ensured no secrets or keys are committed to the repo?
