# ============================================================================
# VARIABLES DE CONFIGURACIÓN - NETWORKING INFRASTRUCTURE
# ============================================================================
# Variables siguiendo PC-IAC-002: Variables de Gobernanza y Configuración
# ============================================================================

# ----------------------------------------------------------------------------
# VARIABLES DE GOBERNANZA (PC-IAC-002)
# ----------------------------------------------------------------------------
variable "client" {
  description = "Nombre del cliente (máx 10 caracteres)"
  type        = string
  validation {
    condition     = length(var.client) <= 10
    error_message = "El nombre del cliente no debe exceder 10 caracteres"
  }
}

variable "project" {
  description = "Nombre del proyecto (máx 15 caracteres)"
  type        = string
  validation {
    condition     = length(var.project) <= 15
    error_message = "El nombre del proyecto no debe exceder 15 caracteres"
  }
}

variable "environment" {
  description = "Ambiente de despliegue"
  type        = string
  validation {
    condition     = contains(["dev", "qa", "pdn"], var.environment)
    error_message = "El ambiente debe ser: dev, qa o pdn"
  }
}

variable "region" {
  description = "Región de AWS donde se desplegará la infraestructura"
  type        = string
  default     = "us-east-1"
}

# ----------------------------------------------------------------------------
# CONFIGURACIÓN DE VPC
# ----------------------------------------------------------------------------
variable "vpc_cidr" {
  description = "CIDR block para la VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames en la VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar DNS support en la VPC"
  type        = bool
  default     = true
}

# ----------------------------------------------------------------------------
# CONFIGURACIÓN DE SUBNETS
# ----------------------------------------------------------------------------
variable "public_subnets" {
  description = "Configuración de subnets públicas"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "1a" = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    }
    "1b" = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  }
}

variable "private_subnets" {
  description = "Configuración de subnets privadas"
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    "app-1a" = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "us-east-1a"
    }
    "app-1b" = {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "us-east-1b"
    }
    "data-1a" = {
      cidr_block        = "10.0.21.0/24"
      availability_zone = "us-east-1a"
    }
    "data-1b" = {
      cidr_block        = "10.0.22.0/24"
      availability_zone = "us-east-1b"
    }
  }
}

# ----------------------------------------------------------------------------
# CONFIGURACIÓN DE VPC ENDPOINTS
# ----------------------------------------------------------------------------
variable "interface_endpoints" {
  description = "Lista de servicios para VPC Endpoints de tipo Interface"
  type        = list(string)
  default = [
    "ecr.api",
    "ecr.dkr",
    "secretsmanager",
    "logs",
    "kinesis-streams"
  ]
}

# ----------------------------------------------------------------------------
# TAGS ADICIONALES (PC-IAC-004)
# ----------------------------------------------------------------------------
variable "additional_tags" {
  description = "Tags adicionales para aplicar a todos los recursos"
  type        = map(string)
  default     = {}
}
