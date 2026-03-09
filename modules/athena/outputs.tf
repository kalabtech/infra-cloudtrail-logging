output "workgroup_name" {
  description = "Athena workgroup name"
  value       = aws_athena_workgroup.this.name
}

output "database_name" {
  description = "Glue database name"
  value       = aws_glue_catalog_database.this.name
}

output "table_name" {
  description = "Glue table name"
  value       = aws_glue_catalog_table.this.name
}
