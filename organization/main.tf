terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_organizations_organization" "management" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
    "sso.amazonaws.com",
    "ram.amazonaws.com", # AWS Ram integration with AWS Organizations allows us to share resources into Organizational Units
    "securityhub.amazonaws.com",
    "guardduty.amazonaws.com",
  ]
  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    "AISERVICES_OPT_OUT_POLICY",
  ]
  feature_set = "ALL"
}

# Create OU hierarchy
resource "aws_organizations_organizational_unit" "development" {
  name      = "development"
  parent_id = aws_organizations_organization.management.roots[0].id
}

resource "aws_organizations_organizational_unit" "shared_services" {
  name      = "shared_services"
  parent_id = aws_organizations_organization.management.roots[0].id
}

resource "aws_organizations_account" "shared_development" {
  email     = "cloud-team+shared-development@acme.com"
  name      = "acme-shared-development"
  parent_id = aws_organizations_organizational_unit.shared_services.id
  tags = {
    environment = "shared-development"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "dev1" {
  email     = "cloud-team+dev1@acme.com"
  name      = "acme-dev1"
  parent_id = aws_organizations_organizational_unit.development.id
  tags = {
    environment = "dev1"
  }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "dev2" {
  email     = "cloud-team+dev2@acme.com"
  name      = "acme-dev2"
  parent_id = aws_organizations_organizational_unit.development.id
  tags = {
    environment = "dev2"
  }
  lifecycle {
    prevent_destroy = true
  }
}
