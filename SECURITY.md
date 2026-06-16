# Security Policy

## Supported Versions

| Version | Supported |
|---|---|
| v1.x | Yes |
| v0.x | Best effort |

## Reporting Security Issues

Security issues should be reported to the GSOC Cloud Platform Engineering and Security teams.

Do not open public issues for:

- Secrets
- Credentials
- Private keys
- Tenant IDs
- Subscription IDs
- Network diagrams containing sensitive paths
- NERC/CIP-sensitive information
- BES Cyber System Information
- CEII-related details

## Security Expectations

All modules must follow these principles:

- Disable public access by default where practical
- Enforce TLS 1.2 or higher
- Support diagnostic settings
- Support standard tagging
- Use RBAC where appropriate
- Avoid hardcoded secrets
- Avoid hardcoded subscription IDs
- Avoid hardcoded tenant IDs
- Support private endpoint patterns where applicable

## Required Security Scans

Pull requests should run:

- Checkov
- Trivy IaC
- tflint
- Secret scanning
- terraform validate
- terraform fmt
