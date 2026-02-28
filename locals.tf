# ============================================================================
# LOCALS - CONSTRUCCIÓN DE NOMENCLATURA Y TRANSFORMACIONES
# ============================================================================
# Locals siguiendo PC-IAC-003: Nomenclatura Estándar
# PC-IAC-012: Estructuras de Datos y Reutilización
# ============================================================================

locals {
  # ----------------------------------------------------------------------------
  # PREFIJO DE GOBERNANZA (PC-IAC-003)
  # ----------------------------------------------------------------------------
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # ----------------------------------------------------------------------------
  # NOMBRES DE RECURSOS (PC-IAC-003)
  # ----------------------------------------------------------------------------
  vpc_name                 = "${local.governance_prefix}-vpc"
  igw_name                 = "${local.governance_prefix}-igw"
  public_route_table_name  = "${local.governance_prefix}-rtb-public"
  private_route_table_name = "${local.governance_prefix}-rtb-private"
  s3_gateway_endpoint_name = "${local.governance_prefix}-vpce-s3-gateway"

  # ----------------------------------------------------------------------------
  # TAGS COMUNES (PC-IAC-004)
  # ----------------------------------------------------------------------------
  common_tags = merge(
    {
      Client      = var.client
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )

  # ----------------------------------------------------------------------------
  # MAPEO DE AVAILABILITY ZONES PARA NAT GATEWAYS Y TABLAS DE RUTAS
  # ----------------------------------------------------------------------------
  # Obtener AZs únicas de las subnets públicas
  unique_azs = distinct([for k, v in var.public_subnets : v.availability_zone])

  # Crear mapeo de NAT Gateways por AZ (uno por AZ única)
  nat_gateway_map = {
    for idx, az in local.unique_azs : "nat-${idx + 1}" => {
      availability_zone = az
      subnet_key        = [for k, v in var.public_subnets : k if v.availability_zone == az][0]
    }
  }

  # Crear mapeo de tablas de rutas privadas por AZ
  private_route_table_map = {
    for idx, az in local.unique_azs : az => {
      name    = "${local.governance_prefix}-rtb-private-${replace(az, "${var.region}-", "")}"
      nat_key = "nat-${idx + 1}"
    }
  }

  # Agrupar subnets privadas por AZ
  private_subnets_by_az = {
    for k, v in var.private_subnets : k => {
      subnet_id         = k
      availability_zone = v.availability_zone
      cidr_block        = v.cidr_block
    }
  }
}
