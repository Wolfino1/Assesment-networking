# ============================================================================
# NETWORKING INFRASTRUCTURE - VPC, SUBNETS, GATEWAYS, ENDPOINTS
# ============================================================================
# Este módulo crea una infraestructura de red completa siguiendo las reglas
# PC-IAC de Pragma CloudOps
# ============================================================================

# ============================================================================
# VPC (PC-IAC-020: Seguridad de Red)
# ============================================================================
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    local.common_tags,
    {
      Name = local.vpc_name
    }
  )
}

# ============================================================================
# INTERNET GATEWAY
# ============================================================================
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = local.igw_name
    }
  )
}

# ============================================================================
# SUBNETS PÚBLICAS (PC-IAC-010: for_each)
# ============================================================================
resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.governance_prefix}-subnet-public-${each.key}"
      Type = "Public"
    }
  )
}

# ============================================================================
# SUBNETS PRIVADAS (PC-IAC-010: for_each)
# ============================================================================
resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    local.common_tags,
    {
      Name = "${local.governance_prefix}-subnet-private-${each.key}"
      Type = "Private"
    }
  )
}

# ============================================================================
# ELASTIC IPs PARA NAT GATEWAYS (PC-IAC-010: for_each)
# ============================================================================
resource "aws_eip" "nat" {
  for_each = local.nat_gateway_map

  domain = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${local.governance_prefix}-eip-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# ============================================================================
# NAT GATEWAYS (PC-IAC-010: for_each)
# ============================================================================
resource "aws_nat_gateway" "this" {
  for_each = local.nat_gateway_map

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.value.subnet_key].id

  tags = merge(
    local.common_tags,
    {
      Name = "${local.governance_prefix}-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# ============================================================================
# TABLA DE RUTAS PÚBLICA
# ============================================================================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = local.public_route_table_name
      Type = "Public"
    }
  )
}

# Ruta a Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# Asociación de subnets públicas a la tabla de rutas pública
resource "aws_route_table_association" "public" {
  for_each = var.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# TABLAS DE RUTAS PRIVADAS (UNA POR AZ PARA ALTA DISPONIBILIDAD)
# ============================================================================
resource "aws_route_table" "private" {
  for_each = local.private_route_table_map

  vpc_id = aws_vpc.this.id

  tags = merge(
    local.common_tags,
    {
      Name = each.value.name
      Type = "Private"
      AZ   = each.key
    }
  )
}

# Rutas a NAT Gateways (cada tabla apunta a su NAT Gateway en la misma AZ)
resource "aws_route" "private_nat" {
  for_each = local.private_route_table_map

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[each.value.nat_key].id
}

# Asociación de subnets privadas a sus tablas de rutas correspondientes por AZ
resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.value.availability_zone].id
}

# ============================================================================
# S3 GATEWAY ENDPOINT (PC-IAC-020: Conectividad Privada)
# ============================================================================
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [for rt in aws_route_table.private : rt.id]

  tags = merge(
    local.common_tags,
    {
      Name = local.s3_gateway_endpoint_name
      Type = "Gateway"
    }
  )
}

# ============================================================================
# SECURITY GROUP PARA VPC ENDPOINTS (PC-IAC-020: Mínimo Privilegio)
# ============================================================================
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${local.governance_prefix}-sg-vpce-"
  description = "Security group for VPC Endpoints"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.governance_prefix}-sg-vpce"
    }
  )
}

# ============================================================================
# VPC ENDPOINTS DE TIPO INTERFACE (PC-IAC-010: for_each)
# ============================================================================
resource "aws_vpc_endpoint" "interface" {
  for_each = toset(var.interface_endpoints)

  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${var.region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [for k, v in aws_subnet.private : v.id]
  security_group_ids  = [aws_security_group.vpc_endpoints.id]
  private_dns_enabled = true

  tags = merge(
    local.common_tags,
    {
      Name = "${local.governance_prefix}-vpce-${each.value}"
      Type = "Interface"
    }
  )
}
