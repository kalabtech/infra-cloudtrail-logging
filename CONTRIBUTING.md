## Workflow

1. Branch from `dev` - develop and test changes on a feature branch
2. Open a PR to `dev` - Terraform plan runs automatically, review the output before merging
3. Merge to `dev` - Terraform apply runs automatically, changes deployed to dev
4. Open a PR from `dev` to `main` - Terraform plan runs against prod for a final review
5. Merge to `main` - Terraform apply runs automatically, changes deployed to prod
