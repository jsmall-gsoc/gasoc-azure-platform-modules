# ADR-001: Use Terraform for Infrastructure as Code

## Status
Accepted

## Context
GASOC requires repeatable, auditable, and governed Azure deployments. Manual portal deployments create inconsistency, drift, and operational risk.

## Decision
Terraform will be used as the primary Infrastructure as Code tool for Azure Landing Zone and platform resource deployment.

## Consequences
- Infrastructure changes are reviewed through pull requests.
- Terraform state must be stored securely.
- Modules must be versioned and reused.
- Azure DevOps pipelines will enforce validation and security checks.
