terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Estos valores los pasa GitHub Actions via -backend-config en el terraform init
    # No se hardcodean aquí para que funcione con cualquier cuenta de Academy
    # (las credenciales de Academy cambian cada sesión)
  }
}

provider "aws" {
  region = var.aws_region
}
