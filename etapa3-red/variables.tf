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