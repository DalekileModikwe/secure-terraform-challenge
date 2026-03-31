# Terraform Challenge Submission

This repository provisions a secure AWS reference architecture for a microservices platform with three subnet tiers: `public`, `private`, and `isolated`. The design is intentionally infrastructure-only and targets workload accounts created through AWS Control Tower, with identity coming from AWS IAM Identity Center in the management account.

This implementation favors reusable Terraform modules, explicit naming, and comments that explain intent and tradeoffs rather than restating syntax. That comment style follows the same principle repeated throughout the HashiCorp variable guidance and the common comment conventions.

The layout separates reusable building blocks into `generic_*` modules and workload-specific composition into `solution_*` modules. The root `main.tf` now orchestrates layers only, rather than carrying individual AWS resources inline.

## Architecture Overview

The deployed flow is:

1. Client calls a public Regional API Gateway endpoint.
2. AWS WAF protects the public API stage.
3. API Gateway invokes a broker Lambda in private subnets.
4. The broker Lambda forwards the request to a Private API Gateway endpoint reachable only through an `execute-api` VPC endpoint.
5. The private API invokes an isolated Lambda in isolated subnets.
6. The isolated Lambda writes processed data to an encrypted S3 bucket and returns only non-sensitive metadata.
7. S3 optionally replicates processed objects to a second-region DR bucket.

Key implementation decisions:

- Public subnets host only edge networking resources such as NAT gateways.
- Private subnets allow controlled egress through NAT for the broker Lambda.
- Isolated subnets have no default internet route, so the sensitive Lambda cannot reach the public internet even if its security group were changed later.
- An S3 gateway endpoint keeps bucket access inside the AWS network path.
- A Private API Gateway plus a restrictive resource policy creates a clean security boundary between the broker tier and the sensitive processing tier.
- Cross-region S3 replication gives the submission a concrete DR control instead of leaving disaster recovery as documentation only.

## Project Structure

```text
.
├── backend.tf
├── environments/
├── lambda-src/
├── modules/
│   ├── generic_*/
│   └── solution_*/
├── docs/
├── FAQ.md
├── Coding-Policy.md
└── README.md
```

## Naming Convention

All generated resource names follow the requested pattern:

`{project-name}-{resource-type-name}-{environment-name}-{provider-alias-name}-{optional-descriptors}-{index}`

## State and Backend

The repository uses a partial `s3` backend block on purpose. Each workload account should supply its own backend settings at init time so the code stays reusable.

```powershell
terraform init `
  -backend-config="bucket=terraform-demo-dev-tfstate-123456789012" `
  -backend-config="key=networking/terraform.tfstate" `
  -backend-config="region=af-south-1" `
  -backend-config="dynamodb_table=terraform-demo-dev-tflock" `
  -backend-config="encrypt=true"
```

## Deployment

```powershell
terraform init
terraform fmt -recursive
terraform validate
terraform plan -var-file="environments/dev.tfvars"
terraform apply -var-file="environments/dev.tfvars"
```

## Assumptions

- Control Tower and Identity Center are already enabled in the management account.
- Deployment happens in workload accounts only: `dev`, `test`, `beta`, and `prod`.
- Shared logging, audit, and organization guardrails already exist in the landing zone.
- The sample Lambda code only proves the infrastructure flow and should be replaced by real artifacts in a delivery pipeline.

## NFR Coverage

Coverage notes live in [docs/nfr-coverage.md](./docs/nfr-coverage.md).

## How AI Was Used

AI was used to accelerate scaffolding, documentation drafting, and consistency checks. The resulting code was then constrained against the PDF brief, the NFR CSV, HashiCorp input-variable guidance, and the workload-account assumptions before validation.
