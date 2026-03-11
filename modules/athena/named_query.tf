resource "aws_athena_named_query" "who_deleted_bucket" {
  name      = "who-deleted-bucket"
  database  = aws_glue_catalog_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = file("${path.module}/queries/who-deleted-bucket.sql")
}

resource "aws_athena_named_query" "failed_console_logins" {
  name      = "failed-console-logins"
  database  = aws_glue_catalog_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = file("${path.module}/queries/failed-console-logins.sql")
}

resource "aws_athena_named_query" "iam_changes" {
  name      = "iam-changes"
  database  = aws_glue_catalog_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = file("${path.module}/queries/iam-changes.sql")
}

resource "aws_athena_named_query" "security_group_changes" {
  name      = "security-group-changes"
  database  = aws_glue_catalog_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = file("${path.module}/queries/security-group-changes.sql")
}

resource "aws_athena_named_query" "resource_creation_by_user" {
  name      = "resource-creation-by-user"
  database  = aws_glue_catalog_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = file("${path.module}/queries/resource-creation-by-user.sql")
}

resource "aws_athena_named_query" "root_account_usage" {
  name      = "root-account-usage"
  database  = aws_glue_catalog_database.this.name
  workgroup = aws_athena_workgroup.this.name
  query     = file("${path.module}/queries/root-account-usage.sql")
}
