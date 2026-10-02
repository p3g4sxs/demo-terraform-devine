terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "terraform-workshop"
}

# Provider adicional en us-east-1 para certificados ACM (requerido por CloudFront)
provider "aws" {
  alias   = "us_east_1"
  region  = "us-east-1"
  profile = "terraform-workshop"
}
