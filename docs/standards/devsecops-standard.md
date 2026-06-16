# DevSecOps Standard for Terraform Modules

## Required Pipeline Gates

- Terraform format check
- Terraform validation
- tflint
- Checkov
- Trivy IaC scan
- Secret scanning
- Pull request review
- CODEOWNERS approval

## Pull Request Controls

Pull requests must include:

- Security impact
- Cost impact
- Operational impact
- Rollback considerations
- Testing evidence

## Security Tools

Recommended tools:

- Checkov
- Trivy
- tflint
- Gitleaks or Microsoft Security DevOps
- terraform-docs
