# ============================================================================
# TERRAFORM VARIABLES - NETWORKING INFRASTRUCTURE
# ============================================================================
# Archivo de valores para las variables de configuración
# ============================================================================

# ----------------------------------------------------------------------------
# VARIABLES DE GOBERNANZA
# ----------------------------------------------------------------------------
client      = "pragma"
project     = "Assesment"
environment = "dev"
region      = "us-east-1"

# ----------------------------------------------------------------------------
# CONFIGURACIÓN DE VPC
# ----------------------------------------------------------------------------
vpc_cidr             = "10.0.0.0/16"
enable_dns_hostnames = true
enable_dns_support   = true

# ----------------------------------------------------------------------------
# CONFIGURACIÓN DE SUBNETS PÚBLICAS
# ----------------------------------------------------------------------------
public_subnets = {
  "1a" = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
  }
  "1b" = {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
  }
}

# ----------------------------------------------------------------------------
# CONFIGURACIÓN DE SUBNETS PRIVADAS
# ----------------------------------------------------------------------------
# Subnets para capa de aplicación (app)
private_subnets = {
  "app-1a" = {
    cidr_block        = "10.0.11.0/24"
    availability_zone = "us-east-1a"
  }
  "app-1b" = {
    cidr_block        = "10.0.12.0/24"
    availability_zone = "us-east-1b"
  }
  # Subnets para capa de datos (data)
  "data-1a" = {
    cidr_block        = "10.0.21.0/24"
    availability_zone = "us-east-1a"
  }
  "data-1b" = {
    cidr_block        = "10.0.22.0/24"
    availability_zone = "us-east-1b"
  }
}

# ----------------------------------------------------------------------------
# CONFIGURACIÓN DE VPC ENDPOINTS
# ----------------------------------------------------------------------------
# Endpoints necesarios para ECS Fargate con Kinesis y logs básicos
interface_endpoints = [
  "ecr.api",        # ECR API - Obligatorio para autenticación ECR
  "ecr.dkr",        # ECR Docker - Obligatorio para pull de imágenes
  "secretsmanager", # Secrets Manager - Para secrets en task definitions
  "logs",           # CloudWatch Logs - Para logs básicos (sin Container Insights)
  "kinesis-streams" # Kinesis Data Streams - Para enviar eventos desde ECS
]

# ----------------------------------------------------------------------------
# TAGS ADICIONALES
# ----------------------------------------------------------------------------
additional_tags = {
  owner      = "Santiago.Guerrero"
  CostCenter = "00000"
  Terraform  = "true"
  Purpose    = "Networking Infrastructure"
}
