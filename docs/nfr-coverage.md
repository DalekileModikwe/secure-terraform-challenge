# NFR Coverage Assessment

This document maps the repository against the supplied `Non-Functional-Requirements.csv`.

## Coverage Summary

- Directly implemented in Terraform: 34
- Addressed through documented operating model or landing-zone assumption: 39
- Partially addressed or deferred: 13

## Directly Implemented

- Multi-AZ subnet layout and zonal-aware deployment.
- Public API load distribution through API Gateway.
- Lambda and API Gateway autoscaling characteristics.
- Cross-region S3 replication for disaster recovery.
- Encryption in transit and at rest.
- WAF protection on the public API.
- Private compute in isolated subnets.
- CloudWatch logging, metrics, and alarms.
- Infrastructure as code, versioned configuration, and provider version pinning.

## Addressed Through Operating Model or Landing-Zone Assumptions

- DR testing, restore drills, and formal runbooks.
- Identity Center, Secrets Manager, SCPs, and wider security operations tooling.
- Centralized log search, SIEM escalation, and dashboarding.
- CI/CD approvals, artifact storage, and release controls.
- Data governance controls that belong in the application or data platform.

## Partially Addressed or Deferred

- Synthetic health checks and deeper dependency monitoring.
- Advanced API authentication.
- Full operational dashboards and runbook automation.
- Application-layer tenant isolation and referential integrity.
