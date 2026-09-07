output "instance_id" {
  description = "ID de la instancia para Session Manager"
  value       = aws_instance.web.id
}

output "ip_publica" {
  description = "IP pública del servidor web"
  value       = aws_instance.web.public_ip
}

output "url" {
  description = "URL para verificar el despliegue"
  value       = "http://${aws_instance.web.public_dns}"
}