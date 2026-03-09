# CI/CD Pipeline - infra-multienv

## Overview

This repo uses GitHub Actions with OIDC authentication against AWS. No static credentials stored - roles are assumed dynamically per workflow and environment.

---

## Triggers

| Event | Branch | Workflow | Environment |
|---|---|---|---|
| `push` / `pull_request` | `feature/**`, `dev`, `main` | `terraform-checks.yml` | - |
| `pull_request` | `dev` | `terraform-plan.yml` | `dev` |
| `push` (merge) | `dev` | `terraform-apply.yml` | `dev` |
| `pull_request` | `main` | `terraform-plan.yml` | `prod` |
| `push` (merge) | `main` | `terraform-apply.yml` | `prod` |
| `schedule` (06:00 UTC daily) / `workflow_dispatch` | - | `drift-detection.yml` | `dev` + `prod` |

---

## Branch Strategy

```
feature/** -> dev -> main
```

- `feature/**` -> checks only (fmt, validate, tfsec)
- `dev` -> plan + apply to **dev**
- `main` -> plan + apply to **prod**

---

## CI/CD Flow

```
[ ANY BRANCH / PR ]

  push / PR -> terraform-checks
                 |-- terraform fmt -check
                 |-- terraform validate
                 +-- tfsec

        |
        | PR -> dev
        v

[ DEV ]

  PR opened -> terraform-plan (dev)
                 |-- OIDC -> assume tf-plan-dev
                 |-- terraform init (backend: dev)
                 +-- terraform plan -> comment on PR

  PR merged -> terraform-apply (dev)
                 |-- OIDC -> assume tf-apply-dev
                 |-- terraform init (backend: dev)
                 +-- terraform apply -auto-approve

        |
        | PR -> main
        v

[ PROD ]

  PR opened -> terraform-plan (prod)
                 |-- OIDC -> assume tf-plan-prod
                 |-- terraform init (backend: prod)
                 +-- terraform plan -> comment on PR

  PR merged -> terraform-apply (prod)
                 |-- OIDC -> assume tf-apply-prod
                 |-- terraform init (backend: prod)
                 +-- terraform apply -auto-approve


[ DRIFT DETECTION ]  (daily 06:00 UTC or manual trigger)

  -> terraform-plan (dev)   -> diff? -> fail
  -> terraform-plan (prod)  -> diff? -> fail
```

---

## IAM Roles per Workflow

| Role | Permissions | Used by |
|---|---|---|
| `tf-plan-dev` | `ReadOnlyAccess` | plan on PRs -> dev |
| `tf-apply-dev` | write scoped to `*dev*` resources | apply on merge -> dev |
| `tf-plan-prod` | `ReadOnlyAccess` | plan on PRs -> main |
| `tf-apply-prod` | write scoped to `*prod*` resources | apply on merge -> main |

Roles defined in **infra-core**. Each role trusts only this repo + branch via OIDC condition:

```
token.actions.githubusercontent.com:sub == repo:ORG/infra-multienv:ref:refs/heads/<branch>
```

---

## State Backend per Environment

| Environment | S3 Key | DynamoDB Table |
|---|---|---|
| dev | `infra-multienv/dev/terraform.tfstate` | `tf-locks` |
| prod | `infra-multienv/prod/terraform.tfstate` | `tf-locks` |

State files are fully isolated - no shared state between environments.
