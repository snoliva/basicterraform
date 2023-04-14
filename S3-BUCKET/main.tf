provider "aws" {
  region  = "us-east-1"
  version = "~> 3.0"
}

locals {
  prefix = "${var.prefix}-${terraform.workspace}"
  common_tags = {
    Environment = terraform.workspace
    Project     = var.project
    Owner       = var.contact
    ManageBy    = "Terraform"
  }
}
