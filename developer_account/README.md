# Developer Account

This is an example of a developer account, this account should be in the development
Organizational Unit. And this terraform should be run in the context of an account in that OU.

For this demo we just deploy an EC2 instance in a subnet that is shared into this account. All accounts
in the development OU will have access to the subnets that are being shared from our shared services account, those resources
are created in the [shared](../shared) example.

You will be able to connect to the instance using SSM Session Manager, you can verify DNS resolution of the shared VPC using
the dig command

```commandline
dig db.dev.internal +short
development.cluster-ctjmh9hmd1ab.eu-west-1.rds.amazonaws.com.
development-1.ctjmh9hmd1ab.eu-west-1.rds.amazonaws.com.
10.0.21.173
```

If you want to connect to the cluster you can install the postgres client and connect, the password is output by the
shared terraform example.

```commandline
sudo amazon-linux-extras install postgresql14
psql -h db.dev.internal -U root -d development
```
