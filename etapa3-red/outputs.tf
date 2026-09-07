output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnets_privadas" {
  value = {
    for k, s in aws_subnet.privada : k => s.id
  }
}

output "sg_app_id" {
  description = "SG de la aplicación que se usará en la Etapa 4"
  value       = aws_security_group.app.id
}

output "url_alb" {
  description = "URL pública del servicio"
  value       = "http://${aws_lb.app.dns_name}"
}