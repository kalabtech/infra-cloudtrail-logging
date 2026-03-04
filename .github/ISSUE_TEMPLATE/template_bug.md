---
name: template_bug
about: Document a technical error to find and implement a solution.
title: "[BUG]: Action"
labels: bug
assignees: kalabtech

---

Title Ex: [BUG]: Ex.Timeout error when connecting to EC2 via SSH
---
## Error Description
Terraform fails when trying to create the S3 bucket for the backend because the name is already taken globally.

## Error Logs / Output

<details>
<summary>Click to expand logs</summary>

```hcl
// Pega aquí tu log largo
Error: Reference to undeclared resource
on main.tf line 42, in resource "aws_instance" "web":
42:   vpc_security_group_ids = [aws_security_group.not_exist.id]
```

</details>

## Steps to Reproduce
1. Run `terraform apply`...
2. The error occurs in the following resource: ...

## Solution / Fix
- [ ] Issue identified and root cause found.
- [ ] Fix implemented in code.
- [ ] Post-fix verification successful.
