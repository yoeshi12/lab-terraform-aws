output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnets_publicas_ids" {
  value = [for s in aws_subnet.publica : s.id]
}

output "subnets_privadas_ids" {
  value = [for s in aws_subnet.privada : s.id]
}
