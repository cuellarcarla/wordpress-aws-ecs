terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Opcional: backend S3 para guardar el estado remotamente
  # Descomenta y configura si tienes un bucket S3 disponible en tu cuenta
  # backend "s3" {
  #   bucket = "mi-terraform-state-bucket"
  #   key    = "wordpress-ecs/dev/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

provider "aws" {
  region = var.aws_region
}
