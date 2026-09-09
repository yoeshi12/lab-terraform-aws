locals {
  entorno = "prod"
  prefijo = "${var.nombre_proyecto}-${var.alumno}-${local.entorno}"
}

module "network" {
  source = "../../modules/network"

  prefijo       = local.prefijo
  vpc_cidr      = var.vpc_cidr
  habilitar_nat = var.habilitar_nat
}

module "app" {
  source = "../../modules/app"

  prefijo              = local.prefijo
  region               = var.region
  vpc_id               = module.network.vpc_id
  subnets_publicas_ids = module.network.subnets_publicas_ids
  subnets_privadas_ids = module.network.subnets_privadas_ids
  instance_type        = var.instance_type
  num_instancias       = var.num_instancias
  titulo_pagina        = "Etapa 5 - ${var.alumno} - ${local.entorno}"
}

module "database" {
  source = "../../modules/database"

  prefijo                    = local.prefijo
  vpc_id                     = module.network.vpc_id
  subnets_privadas_ids       = module.network.subnets_privadas_ids
  sg_app_id                  = module.app.sg_app_id
  db_instance_class          = var.db_instance_class
  db_nombre                  = var.db_nombre
  db_usuario                 = var.db_usuario
  db_multi_az                = var.db_multi_az
  db_backup_retention_period = var.db_backup_retention_period
  db_deletion_protection     = var.db_deletion_protection
}

output "url_alb" {
  value = module.app.url_alb
}

output "db_endpoint" {
  value = module.database.db_endpoint
}

output "db_password_wo_version" {
  value = module.database.db_password_wo_version
}
