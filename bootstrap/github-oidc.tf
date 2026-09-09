terraform {
  required_version = ">= 1.11"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

variable "github_repo" {
  description = "Repositorio autorizado en formato usuario/repositorio"
  type        = string
}

variable "github_owner_id" {
  description = "Identificador inmutable del propietario en GitHub"
  type        = string
  default     = "295691934"
}

variable "github_repository_id" {
  description = "Identificador inmutable del repositorio en GitHub"
  type        = string
  default     = "1362949081"
}

locals {
  github_partes = split("/", var.github_repo)

  github_subject_repo = "${local.github_partes[0]}@${var.github_owner_id}/${local.github_partes[1]}@${var.github_repository_id}"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

resource "aws_iam_role" "github_actions" {
  name = "github-actions-terraform-lab"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${local.github_subject_repo}:*"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "admin_temporal" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "role_arn" {
  value = aws_iam_role.github_actions.arn
}
