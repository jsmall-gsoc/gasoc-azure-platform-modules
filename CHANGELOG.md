# Changelog

All notable changes to this repository are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- **NERC CIP Compliance Framework** (CIP-002 through CIP-014)
  - Comprehensive compliance mapping documentation
  - Policy-as-code enforcement patterns
  - Architecture Decision Records (ADRs) for major decisions
  - Phase-3 governance example with full policy enforcement
- New `subscription-bootstrap` module for NERC CIP-compliant subscriptions
- Enhanced policy assignment module with NERC CIP control library
- TFLint configuration guide for code quality (NERC-aligned)
- Checkov security scanning guide with CIP-specific checks
- Contributing guidelines with NERC CIP compliance requirements
- Extended ADR documentation:
  - ADR-001: NERC CIP Compliance Framework
  - ADR-002: Hub-and-Spoke Network Topology
  - ADR-003: Managed Identity Authentication
  - ADR-004: Encryption-by-Default Strategy
  - ADR-005: Multi-Subscription Architecture
  - ADR-006: Change Management via Git
  - ADR-007: Three-Phase Deployment Model

### Changed
- Updated all module templates to include NERC CIP compliance mapping
- Enhanced diagnostic settings enforcement (CIP-008)
- Strengthened RBAC validation (CIP-004)
- Improved Key Vault security controls (CIP-011)
- Updated Module README structure with compliance sections

### Security
- **CRITICAL**: Encryption now mandatory on all storage and databases (CIP-011)
- **CRITICAL**: Public IP assignment restricted by default (CIP-006/014)
- **HIGH**: Managed identity required for all inter-service authentication (CIP-004)
- **HIGH**: Diagnostic settings now mandatory for compliance audit trails (CIP-008)
- **HIGH**: Network segmentation enforced via NSG deny-by-default (CIP-005)

### Documentation
- docs/NERC_CIP_COMPLIANCE.md - Complete CIP-002 through CIP-014 mapping
- docs/standards/TFLINT_GUIDE.md - Code quality enforcement
- docs/standards/CHECKOV_GUIDE.md - Security scanning integration
- docs/adr/ADR-*.md - Architectural decision records

---

## [1.0.0] - 2026-06-16 (NERC CIP Ready)

### Added
- Complete NERC CIP compliance framework
- ADR documentation structure
- Phase-3 governance with policy enforcement
- Subscription bootstrap automation
- Comprehensive quality gate documentation (tflint + checkov)

### Status
- **Production Ready**: All 23 core modules
- **Maturity**: Production Ready for enterprise deployments
- **Compliance**: NERC CIP-002 through CIP-014 ready
- **Testing**: TFLint + Checkov + Terraform validate in CI/CD

---

## [0.2.0] - 2026-06-01

### Added
- CODEOWNERS file
- SECURITY.md
- CONTRIBUTING.md
- Module maturity model
- ADR folder
- Standards documentation
- Enhanced Azure DevOps validation pipeline
- Release validation pipeline
- terraform-docs support
- tflint support
- Checkov support
- Trivy IaC support
- Secret scanning placeholder
- Module examples folder pattern

## [0.1.0] - 2026-06-01

### Added
- Initial GASOC Azure Terraform module library
- Resource Group module
- Storage Account module
- Terraform Backend module
- Log Analytics module
- Key Vault module
- Virtual Network module
- Subnet module
- NSG module
- Route Table module
- VNet Peering module
- Private DNS Zone module
- Private Endpoint module
- Azure Firewall module
- Bastion module
- VPN Gateway module
- Diagnostic Settings module
- Monitor Action Group module
- Monitor Alert module
- Recovery Services Vault module
- Management Groups module
- Policy Assignment module
- NIST SP 800-53 Rev. 5 module
- Defender for Cloud module
