# Contributing Guide

## Branching Strategy

Use the following branch strategy:

```text
main        - production-ready releases
develop     - integration branch
feature/*   - new module changes
bugfix/*    - bug fixes
hotfix/*    - urgent fixes
release/*   - release preparation and stabilization
```

### Branch Naming Conventions

Branch names must follow these patterns for clarity and consistency:

#### Feature Branches
Create feature branches from `develop` when adding new modules or significant module enhancements.

**Format:** `feature/{module-name}/{brief-description}`

**Examples:**
- `feature/azure-firewall/add-diagnostic-settings`
- `feature/virtual-network/vpc-peering-support`
- `feature/general/terraform-state-backend-refactor`

#### Bugfix Branches
Create bugfix branches from `develop` for non-urgent bug fixes within modules.

**Format:** `bugfix/{module-name|general}/{brief-description}`

**Examples:**
- `bugfix/key-vault/fix-purge-protection-policy`
- `bugfix/network-security-group/correct-rule-priority-logic`
- `bugfix/general/update-dependency-versions`

#### Hotfix Branches
Create hotfix branches from `main` for urgent production issues requiring immediate fixes.

**Format:** `hotfix/{module-name|general}/{brief-description}`

**Examples:**
- `hotfix/azure-firewall/security-group-rule-bypass`
- `hotfix/general/critical-terraform-state-corruption`

#### Release Branches
Create release branches from `develop` during release preparation.

**Format:** `release/v{major}.{minor}.{patch}`

**Examples:**
- `release/v1.0.0`
- `release/v1.2.3`
- `release/v2.0.0`

### Naming Guidelines

- Use lowercase letters, hyphens, and forward slashes only
- No spaces or underscores
- Keep descriptions concise (2-4 words max)
- Use present tense verbs when appropriate (`add`, `fix`, `update`, not `added`, `fixed`)
- If referencing a GitHub issue, include the issue number in the description: `feature/azure-firewall/add-rules-#123`

## Branch Protection

The repository enforces Git Flow protections for development and release branches.

- `main` and `develop` are protected branches.
- Direct pushes to `main` and `develop` are prohibited.
- All changes must be merged via pull request.
- `main` requires at least one approving review and CODEOWNERS approval.
- `develop` requires at least one approving review.
- Required checks for protected branches:
  - `terraform fmt`
  - `terraform validate`
  - `tflint`
  - `checkov`
  - `trivy config`
  - `terraform-docs`
- `feature/*`, `bugfix/*`, `hotfix/*`, and `release/*` branches are created from `develop` or `main` as appropriate.

## Pull Request Requirements

Every pull request must include:

- Description of change
- Affected module(s)
- Testing evidence
- Security impact
- Backward compatibility statement
- Updated README if inputs/outputs changed
- Updated CHANGELOG entry

## Required Checks

- terraform fmt
- terraform validate
- tflint
- checkov
- trivy config
- terraform-docs
- CODEOWNERS approval

## Module Design Standard

Each module must include:

```text
main.tf
variables.tf
outputs.tf
README.md
examples/basic/main.tf
```

## Versioning

Use semantic versioning.

```text
MAJOR.MINOR.PATCH
```

Examples:

```text
v1.0.0
v1.1.0
v1.1.1
```

## Breaking Changes

Breaking changes require:

- Major version increment
- Migration notes
- Architecture review
- Security review
