variable "region" {
  description = "Región de AWS donde se despliega el laboratorio"
  type        = string
  default     = "us-east-1"
}

variable "nombre_proyecto" {
  description = "Prefijo para nombrar los recursos"
  type        = string
  default     = "lab-tf"
}

variable "alumno" {
  description = "Identificador del alumno (código o usuario), sin espacios"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.alumno))
    error_message = "Use solo minúsculas, dígitos y guiones."
  }
}

variable "instance_type" {
  description = "Tipo de instancia elegible para la capa gratuita"
  type        = string
  default     = "t3.micro"
}
variable "puerto_http" {
  description = "Puerto utilizado por el servidor web"
  type        = number
  default     = 80

  validation {
    condition     = var.puerto_http >= 1 && var.puerto_http <= 65535
    error_message = "El puerto HTTP debe estar entre 1 y 65535."
  }
}