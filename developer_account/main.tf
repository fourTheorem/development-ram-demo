terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Terraform   = "true"
      Environment = "dev-account-1"
    }
  }
}

# Deploys an EC2 instance in the subnet that is shared _into_ this account. Allows you to test connectivity so shared
# cluster.

module "jump_host" {
  source    = "../modules/ec2_jump_host"
  subnet_id = var.subnet_id
}
