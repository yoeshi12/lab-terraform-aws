terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    http = {
      source  = "hashicorp/http"
      version = "~> 3.6"
    }
  }
}

provider "aws" {
  region = var.region

  # Etiquetas aplicadas a TODOS los recursos:
  # permiten filtrar costos y encontrar recursos huérfanos.
  default_tags {
    tags = {
      Proyecto  = var.nombre_proyecto
      Etapa     = "2"
      GestorIaC = "terraform"
      Alumno    = var.alumno
    }
  }
}