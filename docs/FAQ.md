# FAQ

## What AWS permissions should my permission set have to deploy this project to `dev`?

Use a dedicated Terraform deployment role in the workload account and allow the permission set to assume it through IAM Identity Center. That role needs rights for VPC networking, API Gateway, Lambda, IAM roles and inline policies, S3, CloudWatch Logs, CloudWatch alarms, WAFv2, EC2 security groups, VPC endpoints, and S3 replication configuration, plus access to the remote state bucket and lock table.

## How is `live` auto-deployed in the CI/CD process?

This repository does not provision the CI/CD platform, so the expected workflow is documented rather than built:

1. Pull requests run `terraform fmt -check`, `terraform validate`, static analysis, and `terraform plan`.
2. The plan is attached to the review.
3. Merges to `main` trigger environment-specific deployments.
4. `dev`, `test`, and `beta` can auto-apply after checks if the team allows it.
5. `prod` should require a manual approval before `terraform apply`.

## How do I set up my local environment?

Install Terraform `>= 1.12`, sign in with the AWS CLI through IAM Identity Center, export temporary credentials for the target workload account, initialize the backend, and deploy with the matching environment tfvars file.

## Why are there custom modules instead of one flat root module?

The brief explicitly asked for reusable modules and no hardcoded values. The split keeps naming, VPC, Lambda, API Gateway, S3, and WAF concerns isolated and reusable across environments.

## Why is the public Lambda in private subnets instead of public subnets?

The public entry point is API Gateway, not the Lambda runtime. Keeping Lambda in private subnets avoids exposing compute directly to the internet while still allowing controlled egress through NAT.

## How does the private API stay private?

It uses a `PRIVATE` API Gateway endpoint, an `execute-api` interface VPC endpoint, and a resource policy that denies invocations from any other VPC endpoint source.

## What assumptions did this submission make?

- Management account services such as Control Tower and Identity Center already exist.
- Workload accounts for `dev`, `test`, `beta`, and `prod` already exist.
- Landing-zone accounts such as Log Archive and Audit already provide shared governance controls.
- DNS, certificates, and custom domains are out of scope for this repository.
