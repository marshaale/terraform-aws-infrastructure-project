terraform {
  required_version = ">= 1.5.0"
  backend "s3" {
    bucket       = "2026terraform-state-bucket-example"
    key          = "infrastructure/terraform-aws-infrastructure-project/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
}