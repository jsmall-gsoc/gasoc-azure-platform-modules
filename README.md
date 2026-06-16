# GASOC Azure Terraform Modules

This repository contains reusable Terraform modules for the GASOC Azure Landing Zone implementation.

The repository is intended to function as an internal Azure Platform Engineering product. Application teams and platform engineers should consume versioned module releases through Azure DevOps pipelines rather than copying or manually modifying module code.

## Repository Purpose

This repository provides standardized, secure, reusable Terraform building blocks for:

- Azure Landing Zones
- Management Groups
- Subscription governance
- NIST SP 800-53 Rev. 5 policy assignment
- Hub-and-spoke networking
- Azure DevOps-based DevSecOps deployment
- Monitoring and logging
- Security baselines
- FinOps controls
- Future platform expansion

## Design Principles

- Secure by default
- Modular and reusable
- Version controlled
- Policy aligned
- DevSecOps validated
- Cost-conscious
- NIST SP 800-53 Rev. 5 ready
- Azure Landing Zone compatible
- Azure DevOps pipeline-driven

## Module Maturity Labels

| Maturity | Meaning |
|---|---|
| Experimental | Early development, not approved for production |
| Preview | Functional but requires additional validation |
| Production Ready | Approved for production use |
| Deprecated | Retained for compatibility but should not be used for new deployments |

## Module Categories

| Category | Modules |
|---|---|
| Governance | management-groups, policy-assignment, nist-sp-800-53-r5 |
| Networking | virtual-network, subnet, network-security-group, route-table, vnet-peering, private-dns-zone, private-endpoint, azure-firewall, bastion, vpn-gateway |
| Security | key-vault, defender-for-cloud |
| Operations | log-analytics, diagnostic-settings, monitor-action-group, monitor-alert |
| Platform | resource-group, storage-account, recovery-services-vault |
| DevSecOps | terraform-backend |

## Repository Structure

```text
modules/
  resource-group/
  storage-account/
  log-analytics/
  key-vault/
  virtual-network/
  subnet/
  network-security-group/
  route-table/
  vnet-peering/
  private-dns-zone/
  private-endpoint/
  azure-firewall/
  bastion/
  vpn-gateway/
  diagnostic-settings/
  monitor-action-group/
  monitor-alert/
  recovery-services-vault/
  management-groups/
  policy-assignment/
  nist-sp-800-53-r5/
  defender-for-cloud/
  terraform-backend/
examples/
  phase-1-foundation/
  phase-2-networking/
docs/
  adr/
  standards/
pipelines/
  module-validation.yml
  release-validation.yml
```

## Standard Module Source Format

Use Azure DevOps Git module references and pin to release tags.

```hcl
module "resource_group" {
  source = "git::https://dev.azure.com/<org>/<project>/_git/gasoc-azure-terraform-modules//modules/resource-group?ref=v1.0.0"

  name     = "rg-prod-eus-network"
  location = "eastus"
  tags     = local.tags
}
```

## Recommended Release Strategy

```text
v0.1.0 - Initial module library
v0.2.0 - Security hardening and docs
v0.3.0 - Landing zone production candidate
v1.0.0 - Production-ready baseline
```

## DevSecOps Controls

Every change should pass:

- terraform fmt
- terraform validate
- tflint
- checkov
- trivy config
- secret scanning
- terraform-docs validation
- pull request approval
- CODEOWNERS review


## Module Examples

Every module includes a `examples/basic/main.tf` file. These examples are intended to show how the module is consumed by an environment repository.

Example path:

```text
modules/<module-name>/examples/basic/main.tf
```

The examples are intentionally simple and should be adapted to GASOC-specific subscriptions, resource groups, naming standards, and security requirements before production use.
