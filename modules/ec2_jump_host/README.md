# EC2 Jump Host

A simple module that deploys an EC2 instance in a target subnet. This can be deployed to initially manage
an Aurora Cluster or to test connectivity from another account for example.

## Resources Created

This module creates an IAM role / Instance Profile with the managed `AmazonSSMManagedInstanceCore` policy attached, this makes
it trivial to connect to the instance using SSM Session Manager.

A security group with all egress traffic allowed is created in the VPC of the specified subnet. So in the example where
we are using a subnet that is shared into an account using AWS RAM the security group is created in the context of the shared
VPC which is worth noting. Only subnets can be shared, not security groups, so we create our own.

The latest Amazon Linux 2 ami in the region is chosen automatically.
