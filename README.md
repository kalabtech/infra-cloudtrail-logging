# infra-cloudtrail-logging

> Terraform infrastructure to capture and investigate AWS API activity.
> CloudTrail logs land in KMS-encrypted S3, queryable via Athena with partition projection to avoid full bucket scans.

## Architecture
<img src="docs/architecture/infra-cloudtrail-logging.png" width="800"/>

## Features
- Captures all AWS API activity via CloudTrail (single-region)
- Stores logs in KMS-encrypted S3 with lifecycle policies (Glacier 30d / Delete 90d)
- Query logs with Athena using a static Glue table and partition projection to keep low costs
- Includes 6 ready-to-use SQL queries for common security investigations

## Stack
- **IaC:** Terraform
- **Cloud:** AWS
  - CloudTrail — track all API activity
  - KMS — keeps logs encrypted in S3
  - S3 — stores logs with lifecycle policies
  - Glue Data Catalog — defines the schema for CloudTrail logs
  - Athena — runs SQL queries directly on S3
  - EventBridge — detects security events in real time *(v1.1)*
  - SNS — sends alerts when events are detected *(v1.1)*
- **CI/CD:** GitHub Actions
- **Secrets:** GitHub Secrets + Variables

## Repository Structure
```
infra-cloudtrail-logging/
├── infra/                    # Root Terraform configuration and module orchestration
├── modules/
│   ├── s3-logs/              # KMS key + S3 bucket with encryption and lifecycle policies
│   ├── cloudtrail/           # CloudTrail trail with log file validation
│   └── athena/               # Glue Data Catalog, Athena workgroup and named queries
│       └── queries/          # SQL queries for security investigation
├── backends/                 # Remote backend config per environment (dev/prod)
├── environments/             # Variable definitions per environment (dev/prod)
├── docs/                     # Architecture and CI/CD documentation
└── scripts/                  # Terraform plan summary scripts for CI/CD
```

## Prerequisites
- Terraform `>= 1.14.0`
- AWS Provider `~> 5.0`
- AWS CLI installed and configured with a named profile
- Copy and fill in your values:
  - `environments/dev.tfvars.example` -> `environments/dev.tfvars`
- *(Optional)* S3 remote backend to use with makefile — see [infra-backend](https://github.com/kalabtech/infra-backend)

  - `backends/dev.hcl.example` -> `backends/dev.hcl`
  - `backends/prod.hcl.example` -> `backends/prod.hcl`

## Usage

### Without remote backend (local state)
```bash
terraform -chdir=infra init
terraform -chdir=infra plan -var-file=../environments/dev.tfvars
terraform -chdir=infra apply -var-file=../environments/dev.tfvars
```
### With remote backend (makefile)
```bash
make init ENV=dev
make plan ENV=dev
make apply ENV=dev
```

## Design decisions
- **KMS + S3 in single module** — KMS is only used for this bucket, no reuse case. Keeping them together reduces complexity without losing clarity.
- **Static Glue table over Crawler** — CloudTrail schema doesn't change, so a Crawler adds cost for no benefit.
- **Partition projection** — Athena computes S3 paths from date partitions directly, no full bucket scans.
- **Single-region trail** — cost optimization. Multi-region recommended for production.
- **No hardcoded values** — account ID and credentials in GitHub Secrets, region and environment in GitHub Variables.

## Security Queries
Predefined queries available in Athena under **Saved Queries**. All queries cover the last 90 days and use partition projection for cost-efficient scanning.

| Query | Description |
|-------|-------------|
| `who-deleted-bucket.sql` | Detect S3 bucket deletions |
| `failed-console-logins.sql` | Failed AWS console login attempts |
| `iam-changes.sql` | IAM user/role/policy modifications |
| `security-group-changes.sql` | Security group rule changes |
| `resource-creation-by-user.sql` | Resource creation by principal |
| `root-account-usage.sql` | Root account activity — critical signal |

<details>
<summary>Who deleted a bucket?</summary>
<img src="docs/screenshots/who-deleted-bucket.png" width="800"/>
</details>

<details>
<summary>Failed console logins</summary>
<img src="docs/screenshots/failed-console-logins.png" width="800"/>
</details>

<details>
<summary>IAM changes</summary>
<img src="docs/screenshots/iam-changes.png" width="800"/>
</details>

<details>
<summary>Security group changes</summary>
<img src="docs/screenshots/security-group-changes.png" width="800"/>
</details>

<details>
<summary>Resource creation by user</summary>
<img src="docs/screenshots/resource-creation-by-user.png" width="800"/>
</details>

<details>
<summary>Root account usage</summary>
<img src="docs/screenshots/root-account-usage.png" width="800"/>
</details>
