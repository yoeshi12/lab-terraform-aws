terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

variable "prefijo" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets_privadas_ids" {
  type = list(string)
}

variable "sg_app_id" {
  type = string
}

variable "db_instance_class" {
  type = string
}

variable "db_nombre" {
  type = string
}

variable "db_usuario" {
  type = string
}

variable "db_multi_az" {
  type = bool
}

variable "db_backup_retention_period" {
  type = number
}

variable "db_deletion_protection" {
  type = bool
}
