# AWS Organizations Configuration

This provides an example of how you can use terraform to define an AWS Organization with Organizational Units to 
implement the pattern in the blog post. It also enables trusted access with the AWS RAM Service.

You could run this as-is in a shiny new AWS Account to create an initial Organization and structure, you would just need
to update the email addresses used. If you have an existing Organization you can use this is as a guide or pick and choose
the resources you need.

## What this terraform does

Creates an AWS Organization that has trusted access enabled with Resource Access Manager and some other
services that are typically integrated with AWS Organizations such as Cloudtrial, Config etc

The AWS account that you run this terraform against therefore becomes a Management Account.

It then creates an Organizational Unit hierarchy:

A `shared_services` OU which typically has accounts that provide shared
networking infrastructure etc, we create an AWS account `acme-shared-development` and make it a child of this OU

A `development` OU. We can create an arbitrary number of AWS development accounts and make them children of this OU. This OU
will be the principal that we share AWS resources with using AWS Resource Access Manager. Having all these accounts under
a single OU also allows us to use powerful preventative controls such as applying an SCP to this entire development OU 

We also create an SCP policy that blocks potentially harmful actions and we apply it ot the development OU. The SCP
blocks accounts from leaving the organization, blocks it from disabling detective controls and also blocks
the creation of IAM users, this ensures all programmatic access to the account is via short lived credentials issues by
AWS Identity Centre
