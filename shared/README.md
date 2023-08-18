# Shared Resources

This module should be deployed against your shared development services accounts. It creates:

- VPC with database subnets and private subnets
- Aurora Cluster in database subnet
- Database Security Group that allows inbound connections from private subnet CIDR
- Private Route53 Hosted Zone and CNAME record that resolves to cluster endpoint
- The AWS Resource Access Manager resource share, resource association and shares it with the development OU principal.

