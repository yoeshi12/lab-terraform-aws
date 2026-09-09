variable "region" {
  type    = string
  default = "us-east-2"
}

variable "nombre_proyecto" {
  type    = string
  default = "lab-tf"
}

variable "alumno" {
  type = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.alumno))
    error_message = "Use solo minúsculas, dígitos y guiones."
  }
}

variable "vpc_cidr" {
  description = "Bloque CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "num_instancias" {
  description = "Instancias deseadas en el Auto Scaling Group"
  type        = number
  default     = 2
}

variable "habilitar_nat" {
  description = "Crear NAT Gateway. Necesario para las instancias privadas."
  type        = bool
  default     = true
}

variable "db_instance_class" {
  description = "Clase de instancia RDS"
  type        = string
  default     = "db.t4g.micro"
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
  description = "Replica sincronica en otra AZ; usar solo en produccion real"
  type        = bool
  default     = false
}
variable "db_backup_retention_period" {
  description = "Cantidad de días que se conservarán los backups de RDS"
  type        = number
  default     = 0
}

variable "db_deletion_protection" {
  description = "Activa la protección contra eliminación de RDS"
  type        = bool
  default     = false
}