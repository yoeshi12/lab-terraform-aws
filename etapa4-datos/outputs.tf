output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnets_privadas" {
  value = {
    for k, s in aws_subnet.privada : k => s.id
  }
}

output "sg_app_id" {
  description = "SG de la aplicación"
  value       = aws_security_group.app.id
}

output "url_alb" {
  description = "URL pública del servicio"
  value       = "http://${aws_lb.app.dns_name}"
}

output "db_endpoint" {
  description = "Endpoint de PostgreSQL"
  value       = aws_db_instance.postgres.address
}

output "db_secret_arn" {
  description = "ARN del secreto administrado por RDS"
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "entorno" {
  value = terraform.workspace
}