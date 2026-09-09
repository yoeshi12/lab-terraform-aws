variable "prefijo" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnets_publicas_ids" {
  type = list(string)
}

variable "subnets_privadas_ids" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "num_instancias" {
  type = number
}

variable "region" {
  type = string
}

variable "titulo_pagina" {
  type = string
}
