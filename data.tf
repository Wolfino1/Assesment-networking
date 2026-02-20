# ============================================================================
# DATA SOURCES
# ============================================================================
# Data sources para obtener información de recursos existentes
# Siguiendo PC-IAC-011: Data Sources y Consumo de Datos Externos
# ============================================================================

# Data source para obtener la región actual
data "aws_region" "current" {}

# Data source para obtener la cuenta de AWS actual
data "aws_caller_identity" "current" {}

# Data source para obtener las zonas de disponibilidad
data "aws_availability_zones" "available" {
  state = "available"
}
