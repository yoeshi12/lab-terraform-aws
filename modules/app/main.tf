# Security Group del balanceador: recibe HTTP desde Internet
resource "aws_security_group" "alb" {
  name        = "${var.prefijo}-sg-alb"
  description = "ALB: HTTP desde Internet"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.prefijo}-sg-alb"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  description       = "HTTP publico hacia el ALB"
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb_todo" {
  description       = "Salida del ALB"
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Security Group de la aplicación: solo recibe tráfico del ALB
resource "aws_security_group" "app" {
  name        = "${var.prefijo}-sg-app"
  description = "App: HTTP solo desde el ALB"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.prefijo}-sg-app"
  }
}

resource "aws_vpc_security_group_ingress_rule" "app_desde_alb" {
  description                  = "HTTP desde el ALB hacia la aplicacion"
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "app_todo" {
  description       = "Salida de la aplicacion"
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# PostgreSQL: solo acepta conexiones desde las instancias de la aplicacion

resource "aws_lb" "app" {
  #checkov:skip=CKV2_AWS_28:WAF se omite temporalmente en dev por costo; sera obligatorio en produccion.
  name                       = "${var.prefijo}-alb"
  load_balancer_type         = "application"
  drop_invalid_header_fields = true
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.subnets_publicas_ids

  tags = {
    Name = "${var.prefijo}-alb"
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.prefijo}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 15
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
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
  name = "${var.prefijo}-ec2-ssm"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.prefijo}-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

# ---------- Plantilla de lanzamiento ----------

resource "aws_launch_template" "app" {
  name_prefix   = "${var.prefijo}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.app.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }

  metadata_options {
    http_tokens = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = 8
      volume_type = "gp3"
      encrypted   = true
    }
  }

  # La página muestra el hostname para comprobar el balanceo
  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf install -y nginx postgresql16
    echo "<h1>${var.titulo_pagina}</h1><p>Atendido por: $(hostname -f)</p>" \
      > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.prefijo}-app"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------- Auto Scaling Group ----------

resource "aws_autoscaling_group" "app" {
  name                      = "${var.prefijo}-asg"
  desired_capacity          = var.num_instancias
  min_size                  = 1
  max_size                  = 3
  vpc_zone_identifier       = var.subnets_privadas_ids
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.prefijo}-app"
    propagate_at_launch = true
  }
}

# Permite que las EC2 lean los parametros de este entorno
resource "aws_iam_role_policy" "leer_parametros" {
  name = "${var.prefijo}-leer-parametros"
  role = aws_iam_role.ec2_ssm.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "ssm:GetParameters"
      ]
      Resource = "arn:aws:ssm:${var.region}:*:parameter/${var.prefijo}/*"
    }]
  })
}