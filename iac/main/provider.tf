provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.builder_role_arn
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
