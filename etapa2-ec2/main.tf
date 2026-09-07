locals {
  prefijo = "${var.nombre_proyecto}-${var.alumno}"
}

# ---------- Datos existentes ----------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# ---------- IAM para Session Manager ----------

resource "aws_iam_role" "ec2_ssm" {
  name = "${local.prefijo}-ec2-ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${local.prefijo}-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

# ---------- Seguridad perimetral ----------

resource "aws_security_group" "web" {
  name        = "${local.prefijo}-sg-web"
  description = "HTTP entrante desde Internet; sin SSH"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "${local.prefijo}-sg-web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.web.id
  description       = "HTTP"
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "todo" {
  security_group_id = aws_security_group.web.id
  description       = "Salida sin restricciones (actualizaciones, SSM)"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# ---------- Instancia EC2 ----------

resource "aws_instance" "web" {
  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>Etapa 2 - Servidor de ${var.alumno} desplegado con Terraform</h1>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${local.prefijo}-web"
  }
}