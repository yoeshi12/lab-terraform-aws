output "sg_app_id" {
  value = aws_security_group.app.id
}

output "url_alb" {
  value = "http://${aws_lb.app.dns_name}"
}
