# ADR-004: Use Azure DevOps for CI/CD

## Status
Accepted

## Context
GASOC Terraform code will be housed in Azure DevOps repositories and deployed through approved pipelines.

## Decision
Azure DevOps Repos and Azure Pipelines will be used for Terraform validation and deployment.

## Consequences
- Pull request-based change control.
- Pipeline-based approvals.
- DevSecOps controls can be standardized.
- Environment deployments can be separated by stage.
