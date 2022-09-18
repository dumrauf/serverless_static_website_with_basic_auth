terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region                   = var.region
  shared_credentials_files = [var.shared_credentials_file]
  profile                  = var.profile
}
