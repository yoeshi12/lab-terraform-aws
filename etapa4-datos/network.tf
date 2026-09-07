locals {
  entorno = terraform.workspace
  prefijo = "${var.nombre_proyecto}-${var.alumno}-${local.entorno}"

  azs              = slice(data.aws_availability_zones.disponibles.names, 0, 2)
  subnets_publicas = { for i, az in local.azs : az => cidrsubnet(var.vpc_cidr, 8, i) }
  subnets_privadas = { for i, az in local.azs : az => cidrsubnet(var.vpc_cidr, 8, i + 10) }
}

data "aws_availability_zones" "disponibles" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${local.prefijo}-vpc"
  }
}

# ---------- Subnets ----------

resource "aws_subnet" "publica" {
  for_each                = local.subnets_publicas
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "${local.prefijo}-publica-${each.key}"
    Tipo = "publica"
  }
}

resource "aws_subnet" "privada" {
  for_each          = local.subnets_privadas
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = {
    Name = "${local.prefijo}-privada-${each.key}"
    Tipo = "privada"
  }
}

# ---------- Salida a Internet ----------

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefijo}-igw"
  }
}

# Un solo NAT Gateway para reducir el costo
resource "aws_eip" "nat" {
  count  = var.habilitar_nat ? 1 : 0
  domain = "vpc"

  tags = {
    Name = "${local.prefijo}-eip-nat"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = var.habilitar_nat ? 1 : 0
  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.publica[local.azs[0]].id

  tags = {
    Name = "${local.prefijo}-nat"
  }

  depends_on = [aws_internet_gateway.igw]
}

# ---------- Ruteo ----------

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.prefijo}-rt-publica"
  }
}

resource "aws_route_table_association" "publica" {
  for_each       = aws_subnet.publica
  subnet_id      = each.value.id
  route_table_id = aws_route_table.publica.id
}

resource "aws_route_table" "privada" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${local.prefijo}-rt-privada"
  }
}

resource "aws_route" "privada_nat" {
  count                  = var.habilitar_nat ? 1 : 0
  route_table_id         = aws_route_table.privada.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[0].id
}

resource "aws_route_table_association" "privada" {
  for_each       = aws_subnet.privada
  subnet_id      = each.value.id
  route_table_id = aws_route_table.privada.id
}