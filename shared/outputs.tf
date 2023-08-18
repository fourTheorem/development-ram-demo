output "vpc_id" {
  value = module.vpc.vpc_id
}

output "dns_record" {
  value = aws_route53_record.rds_endpoint.fqdn
}

output "subnets" {
  value = module.vpc.private_subnets
}

# This is not typically a good idea, but we're doing it for the sake of the demo
# You can manage the password in Secrets Manager which allows you to do auto rotation
# or use RDS Proxy
output "rds_cluster_password" {
  value = nonsensitive(module.db.rds_cluster_master_password)
}
