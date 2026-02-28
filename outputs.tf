# ============================================================================
# OUTPUTS - NETWORKING INFRASTRUCTURE
# ============================================================================
# Outputs siguiendo PC-IAC-007: Outputs Granulares
# ============================================================================

# ----------------------------------------------------------------------------
# VPC OUTPUTS
# ----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block de la VPC"
  value       = aws_vpc.this.cidr_block
}

output "vpc_arn" {
  description = "ARN de la VPC"
  value       = aws_vpc.this.arn
}

# ----------------------------------------------------------------------------
# INTERNET GATEWAY OUTPUTS
# ----------------------------------------------------------------------------
output "internet_gateway_id" {
  description = "ID del Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "internet_gateway_arn" {
  description = "ARN del Internet Gateway"
  value       = aws_internet_gateway.this.arn
}

# ----------------------------------------------------------------------------
# SUBNETS OUTPUTS
# ----------------------------------------------------------------------------
output "public_subnet_ids" {
  description = "IDs de las subnets públicas"
  value       = { for k, v in aws_subnet.public : k => v.id }
}

output "public_subnet_arns" {
  description = "ARNs de las subnets públicas"
  value       = { for k, v in aws_subnet.public : k => v.arn }
}

output "public_subnet_cidr_blocks" {
  description = "CIDR blocks de las subnets públicas"
  value       = { for k, v in aws_subnet.public : k => v.cidr_block }
}

output "private_subnet_ids" {
  description = "IDs de las subnets privadas"
  value       = { for k, v in aws_subnet.private : k => v.id }
}

output "private_subnet_arns" {
  description = "ARNs de las subnets privadas"
  value       = { for k, v in aws_subnet.private : k => v.arn }
}

output "private_subnet_cidr_blocks" {
  description = "CIDR blocks de las subnets privadas"
  value       = { for k, v in aws_subnet.private : k => v.cidr_block }
}

# ----------------------------------------------------------------------------
# NAT GATEWAY OUTPUTS
# ----------------------------------------------------------------------------
output "nat_gateway_ids" {
  description = "IDs de los NAT Gateways"
  value       = { for k, v in aws_nat_gateway.this : k => v.id }
}

output "nat_gateway_public_ips" {
  description = "IPs públicas de los NAT Gateways"
  value       = { for k, v in aws_nat_gateway.this : k => v.public_ip }
}

# ----------------------------------------------------------------------------
# ELASTIC IP OUTPUTS
# ----------------------------------------------------------------------------
output "elastic_ip_ids" {
  description = "IDs de las Elastic IPs"
  value       = { for k, v in aws_eip.nat : k => v.id }
}

output "elastic_ip_addresses" {
  description = "Direcciones IP elásticas asignadas a los NAT Gateways"
  value       = { for k, v in aws_eip.nat : k => v.public_ip }
}

# ----------------------------------------------------------------------------
# ROUTE TABLE OUTPUTS
# ----------------------------------------------------------------------------
output "public_route_table_id" {
  description = "ID de la tabla de rutas pública"
  value       = aws_route_table.public.id
}

output "public_route_table_arn" {
  description = "ARN de la tabla de rutas pública"
  value       = aws_route_table.public.arn
}

output "private_route_table_id" {
  description = "ID de la tabla de rutas privada (deprecated - usar private_route_table_ids)"
  value       = try(aws_route_table.private[local.unique_azs[0]].id, null)
}

output "private_route_table_ids" {
  description = "IDs de las tablas de rutas privadas por AZ"
  value       = { for k, v in aws_route_table.private : k => v.id }
}

output "private_route_table_arns" {
  description = "ARNs de las tablas de rutas privadas por AZ"
  value       = { for k, v in aws_route_table.private : k => v.arn }
}

# ----------------------------------------------------------------------------
# VPC ENDPOINTS OUTPUTS
# ----------------------------------------------------------------------------
output "s3_gateway_endpoint_id" {
  description = "ID del S3 Gateway Endpoint"
  value       = aws_vpc_endpoint.s3_gateway.id
}

output "s3_gateway_endpoint_arn" {
  description = "ARN del S3 Gateway Endpoint"
  value       = aws_vpc_endpoint.s3_gateway.arn
}

output "interface_endpoint_ids" {
  description = "IDs de los VPC Endpoints de tipo Interface"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "interface_endpoint_arns" {
  description = "ARNs de los VPC Endpoints de tipo Interface"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.arn }
}

output "interface_endpoint_dns_entries" {
  description = "DNS entries de los VPC Endpoints de tipo Interface"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.dns_entry }
}

# ----------------------------------------------------------------------------
# SECURITY GROUP OUTPUTS
# ----------------------------------------------------------------------------
output "vpc_endpoints_security_group_id" {
  description = "ID del Security Group para VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.id
}

output "vpc_endpoints_security_group_arn" {
  description = "ARN del Security Group para VPC Endpoints"
  value       = aws_security_group.vpc_endpoints.arn
}

# ----------------------------------------------------------------------------
# SUMMARY OUTPUTS
# ----------------------------------------------------------------------------
output "networking_summary" {
  description = "Resumen de la infraestructura de networking creada"
  value = {
    vpc_id                     = aws_vpc.this.id
    vpc_cidr                   = aws_vpc.this.cidr_block
    public_subnets_count       = length(aws_subnet.public)
    private_subnets_count      = length(aws_subnet.private)
    nat_gateways_count         = length(aws_nat_gateway.this)
    private_route_tables_count = length(aws_route_table.private)
    interface_endpoints_count  = length(aws_vpc_endpoint.interface)
    region                     = var.region
    environment                = var.environment
    availability_zones         = local.unique_azs
  }
}
