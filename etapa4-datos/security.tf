# Security Group del balanceador: recibe HTTP desde Internet
resource "aws_security_group" "alb" {
  name        = "${local.prefijo}-sg-alb"
  description = "ALB: HTTP desde Internet"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.prefijo}-sg-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_todo" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group de la aplicación: solo recibe tráfico del ALB
resource "aws_security_group" "app" {
  name        = "${local.prefijo}-sg-app"
  description = "App: HTTP solo desde el ALB"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.prefijo}-sg-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_desde_alb" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_todo" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# PostgreSQL: solo acepta conexiones desde las instancias de la aplicacion
resource "aws_security_group" "db" {
  name        = "${local.prefijo}-sg-db"
  description = "PostgreSQL solo desde la capa de aplicacion"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${local.prefijo}-sg-db"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_desde_app" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5432
  to_port                      = 5432
  ip_protocol                  = "tcp"
}