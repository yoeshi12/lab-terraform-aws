output "instance_ids" {
  description = "IDs de las dos instancias"
  value       = aws_instance.web[*].id
}

output "ips_publicas" {
  description = "IPs públicas de las dos instancias"
  value       = aws_instance.web[*].public_ip
}

output "urls" {
  description = "URLs de las dos instancias"
  value = [
    for instancia in aws_instance.web :
    "http://${instancia.public_dns}:${var.puerto_http}"
  ]
}