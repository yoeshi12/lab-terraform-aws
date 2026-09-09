variable "region" {
  type    = string
  default = "us-east-2"
}

variable "nombre_proyecto" {
  type    = string
  default = "lab-tf"
}

variable "alumno" {
  type    = string
  default = "2023100941"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.alumno))
    error_message = "Use solo minúsculas, dígitos y guiones."
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "num_instancias" {
  type    = number
  default = 2
}

variable "habilitar_nat" {
  type    = bool
  default = true
}

variable "db_instance_class" {
  type    = string
  default = "db.t4g.micro"
}

variable "db_nombre" {
  type    = string
  default = "appdb"
}

variable "db_usuario" {
  type    = string
  default = "appadmin"
}

variable "db_multi_az" {
  type    = bool
  default = false
}

variable "db_backup_retention_period" {
  type    = number
  default = 1
}

variable "db_deletion_protection" {
  type    = bool
  default = false
}
