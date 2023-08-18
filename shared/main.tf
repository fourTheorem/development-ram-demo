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
      Environment = "shared-dev"
    }
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "shared-dev-vpc"
  cidr = "10.0.0.0/16"

  azs                          = ["eu-west-1a", "eu-west-1b"]
  private_subnets              = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets               = ["10.0.10.0/24", "10.0.11.0/24"]
  database_subnets             = ["10.0.21.0/24", "10.0.22.0/24"]
  create_database_subnet_group = true
  database_subnet_group_name   = "shared-dev"

  enable_nat_gateway = true

  # Flow Logs
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
}

resource "aws_security_group" "development_db" {
  name   = "development_db"
  vpc_id = module.vpc.vpc_id
}

# Note how we just allow port 5432 ingress from the private subnet CIDRs, this is because the security group ID of future
# development account security groups cannot be known at this time. So we just allow the CIDR
resource "aws_security_group_rule" "development_db_ingress" {
  security_group_id = aws_security_group.development_db.id
  type              = "ingress"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  cidr_blocks       = module.vpc.private_subnets_cidr_blocks
}

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "5.3.0"

  name           = "development"
  database_name  = "development"
  engine         = "aurora-postgresql"
  engine_version = "11"
  instance_type  = "db.t3.medium"

  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  create_security_group  = false
  vpc_security_group_ids = [aws_security_group.development_db.id]

  replica_count                       = 1
  iam_database_authentication_enabled = false
  username                            = "root"
  create_random_password              = true

  apply_immediately   = true
  skip_final_snapshot = false

  enabled_cloudwatch_logs_exports = ["postgresql"]
}

# Private DNS. We create a private Route 53 Zone in the VPC, This allows us to create a CNAME record that maps to our
# Aurora endpoint. Any resources deployed in the private shared subnet can take advantage of this DNS resolution
# i.e the cluster can always be referenced as db.dev.internal even in the development accounts.

resource "aws_route53_zone" "private" {
  name = "dev.internal"

  vpc {
    vpc_id = module.vpc.vpc_id
  }
  tags = {
    Terraform   = "true"
    Environment = "shared-dev"
  }
}

resource "aws_route53_record" "rds_endpoint" {
  name    = "db"
  type    = "CNAME"
  ttl     = 60
  zone_id = aws_route53_zone.private.id
  records = [module.db.rds_cluster_endpoint]
}

# We are creating a RAM resource share called development_subnets. This is the private subnet of the VPC defined above
# any resources launched in this subnet will be able to access the database subnet of the VPC.

resource "aws_ram_resource_share" "development_subnets" {
  name                      = "development_subnets"
  allow_external_principals = false
}

resource "aws_ram_resource_association" "development_subnets" {
  for_each           = toset(module.vpc.private_subnet_arns)
  resource_arn       = each.value
  resource_share_arn = aws_ram_resource_share.development_subnets.arn
}

resource "aws_ram_principal_association" "development_ou" {
  principal          = var.development_ou_arn
  resource_share_arn = aws_ram_resource_share.development_subnets.arn
}
