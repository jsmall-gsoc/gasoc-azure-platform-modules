## Architecture Decision Record: NERC CIP Compliance Framework

**ADR-001: Implement NERC CIP Compliance Through Policy-as-Code**

**Status**: Accepted

**Date**: 2026-06-16

### Context

GASOC Azure Terraform Modules must support critical infrastructure workloads subject to NERC (North American Electric Reliability Corporation) CIP standards (CIP-002 through CIP-014). Compliance cannot be optional or manual; it must be enforced through infrastructure automation and governance.

### Decision

We will implement NERC CIP compliance through:

1. **Azure Policy Assignments** - Enforce security and operational requirements at resource creation time
2. **Module-Level Controls** - Built-in compliance patterns within each Terraform module
3. **Tagging Strategy** - Classification-based tagging to enable policy targeting
4. **Audit & Monitoring** - Centralized logging and alerting for compliance violations
5. **Code-Level Validation** - terraform validate + tflint + checkov in CI/CD pipeline

### Rationale

- **Prevention vs. Detection**: Policies prevent non-compliant resources from being created
- **Scalability**: Enforcement applies automatically to all resources
- **Transparency**: Policy assignments are version-controlled and auditable
- **Flexibility**: Policies can be scoped by criticality level (CIP-002 classification)
- **Cost**: Prevents expensive post-deployment remediation

### Consequences

- **Positive**:
  - No manual compliance checks required
  - Audit trail for all policy changes
  - New teams inherit compliance automatically
  - CIP auditors have clear evidence of controls

- **Negative**:
  - Initial policy development effort
  - Requires Azure Policy understanding
  - Policy exceptions need careful justification
  - May impact deployment velocity initially

### Implementation

See `modules/policy-assignment/` for policy definitions.
See `docs/NERC_CIP_COMPLIANCE.md` for control mappings.

---

## ADR-002: Hub-and-Spoke Network Topology for NERC Compliance

**Status**: Accepted

**Date**: 2026-06-16

### Context

NERC CIP-005 and CIP-014 require network segmentation and centralized security controls. The enterprise needs a scalable networking pattern.

### Decision

Adopt **Hub-and-Spoke** topology:
- **Hub**: Centralized firewall, logging, policy enforcement
- **Spokes**: Workload VNets with restricted egress through hub
- **Connectivity**: Private peering + forced tunneling
- **Segmentation**: NSGs at subnet level + DDoS protection

### Rationale

- Meets CIP network segmentation requirements
- Centralized logging (hub)
- Scalable to multiple subscriptions (spokes in different subs)
- Firewall can enforce egress policies
- Standard enterprise pattern

### Implementation

See `examples/phase-2-networking/` for hub-and-spoke deployment.

---

## ADR-003: Managed Identity for All Authentication

**Status**: Accepted

**Date**: 2026-06-16

### Context

NERC CIP-004 requires strong access controls. Shared keys, connection strings, and service principal credentials violate security principles.

### Decision

**No credentials in code.** All inter-service authentication uses:
- System-assigned or user-assigned managed identities
- Workload Identity Federation (cross-cloud scenarios)
- Entra ID Conditional Access policies

### Consequences

- Eliminates credential rotation burden
- Enables fine-grained RBAC
- Supports zero-trust architecture
- Auditable access patterns

### Implementation

All modules use `azurerm_user_assigned_identity` by default.

---

## ADR-004: Encryption-by-Default, No Opt-Out

**Status**: Accepted

**Date**: 2026-06-16

### Context

NERC CIP-011 mandates information protection through encryption. Compliance cannot depend on user configuration.

### Decision

All modules enable encryption at rest and transit by default:
- Managed disk encryption: enabled
- Storage account TLS: 1.2 minimum
- Database TDE: enabled
- Key Vault: soft delete + purge protection
- No variables to disable encryption

### Rationale

- Meets CIP-011 data protection requirements
- Reduces misconfiguration risk
- Aligns with Azure security baselines
- Minimal performance impact

### Consequences

- Cost: Premium SKUs required for some services (acceptable for compliance)
- Complexity: Key rotation must be automated
- Flexibility: Cannot deploy unencrypted resources

---

## ADR-005: Subscription Isolation for Workload Types

**Status**: Accepted

**Date**: 2026-06-16

### Context

NERC CIP requires isolation between:
- Management/control plane
- Production workloads
- Non-production/testing

### Decision

Multi-subscription architecture:
- **Management Subscription**: Policy definitions, central logging, RBAC
- **Production Subscription(s)**: Critical workloads (segregated by app/business unit)
- **Non-Prod Subscription**: Dev/test (different policy scope)

### Implementation

See `modules/management-groups/` for subscription organization.

---

## ADR-006: Change Management via Git + Terraform State Lock

**Status**: Accepted

**Date**: 2026-06-16

### Context

NERC CIP-010 requires configuration management and change tracking. Terraform state must be protected.

### Decision

- **State Storage**: Azure Storage + blob versioning + access restrictions
- **State Lock**: Enabled (prevents concurrent modifications)
- **State Encryption**: Storage Account + Key Vault for CMK
- **Git Workflow**: All changes via PR with approvals
- **Audit Trail**: Azure Policy + git commit history

### Consequences

- No direct `terraform apply` allowed (only via CI/CD)
- State file access highly restricted
- Audit trail provides compliance evidence

---

## ADR-007: Three-Phase Deployment Model

**Status**: Accepted

**Date**: 2026-06-16

### Context

NERC workloads require staged, validated deployments. A sequential phase model manages risk.

### Decision

- **Phase 1 - Foundation**: Resource groups, storage, logging, Key Vault, management groups, policies
- **Phase 2 - Networking**: VNets, subnets, NSGs, firewalls, peering, private endpoints
- **Phase 3 - Governance**: Policy assignments, Entra ID integration, RBAC role assignments, monitoring

### Benefits

- Reduces blast radius
- Enables rollback at each phase
- Clear dependency ordering
- Demonstrates compliance progression

### Implementation

See `examples/phase-1-foundation/`, `examples/phase-2-networking/`, `examples/phase-3-governance/`.
