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

output "db_password_wo_version" {
  description = "Versión de la contraseña write-only"
  value       = aws_db_instance.postgres.password_wo_version
}

output "entorno" {
  value = terraform.workspace
}