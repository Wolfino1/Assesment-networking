# ============================================================================
# PROVIDERS CONFIGURATION
# ============================================================================
# Configuración de providers siguiendo PC-IAC-005
# ============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider principal de AWS
provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}

  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }
}