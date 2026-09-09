output "db_endpoint" {
  value = aws_db_instance.postgres.address
}

output "db_password_wo_version" {
  value = aws_db_instance.postgres.password_wo_version
}
