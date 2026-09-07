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
  name = "${local.prefijo}-ec2-profile"
  role = aws_iam_role.ec2_ssm.name
}

# ---------- Plantilla de lanzamiento ----------

resource "aws_launch_template" "app" {
  name_prefix   = "${local.prefijo}-lt-"
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
    dnf install -y nginx
    echo "<h1>Etapa 3 - ${var.alumno}</h1><p>Atendido por: $(hostname -f)</p>" \
      > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${local.prefijo}-app"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------- Auto Scaling Group ----------

resource "aws_autoscaling_group" "app" {
  name                      = "${local.prefijo}-asg"
  desired_capacity          = var.num_instancias
  min_size                  = 1
  max_size                  = 3
  vpc_zone_identifier       = [for s in aws_subnet.privada : s.id]
  target_group_arns         = [aws_lb_target_group.app.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${local.prefijo}-app"
    propagate_at_launch = true
  }
}