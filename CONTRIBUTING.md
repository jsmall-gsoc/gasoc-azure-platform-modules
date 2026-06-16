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
