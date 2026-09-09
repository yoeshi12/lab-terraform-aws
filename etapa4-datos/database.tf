# Contraseña temporal: existe durante la ejecución, pero no se guarda en el estado
ephemeral "random_password" "db" {
  length  = 24
  special = false
}

# Endpoint de la base de datos almacenado en Parameter Store
resource "aws_ssm_parameter" "db_endpoint" {
  name  = "/${local.prefijo}/db/endpoint"
  type  = "String"
  value = aws_db_instance.postgres.address
}

# Subredes privadas para RDS
resource "aws_db_subnet_group" "db" {
  name       = "${local.prefijo}-dbsubnets"
  subnet_ids = [for s in aws_subnet.privada : s.id]
}

# Base de datos PostgreSQL
resource "aws_db_instance" "postgres" {
  identifier     = "${local.prefijo}-db"
  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_name             = var.db_nombre
  username            = var.db_usuario
  password_wo         = ephemeral.random_password.db.result
  password_wo_version = 1

  db_subnet_group_name   = aws_db_subnet_group.db.name
  vpc_security_group_ids = [aws_security_group.db.id]
  publicly_accessible    = false
  multi_az               = var.db_multi_az

  # Configuración temporal para el laboratorio
  backup_retention_period = var.db_backup_retention_period
  deletion_protection     = var.db_deletion_protection
  skip_final_snapshot     = true
  apply_immediately       = true

  tags = {
    Name = "${local.prefijo}-db"
  }
}