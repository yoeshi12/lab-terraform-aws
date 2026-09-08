terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Proyecto  = var.nombre_proyecto
      Entorno   = terraform.workspace
      Etapa     = "4"
      GestorIaC = "terraform"
      Alumno    = var.alumno
    }
  }
}