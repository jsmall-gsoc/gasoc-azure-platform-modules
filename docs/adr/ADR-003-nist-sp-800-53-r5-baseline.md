# ADR-003: Use NIST SP 800-53 Rev. 5 as Azure Governance Baseline

## Status
Proposed

## Context
GASOC operates in a regulated critical infrastructure environment and requires a defensible security and compliance baseline.

## Decision
The Microsoft built-in NIST SP 800-53 Rev. 5 Azure Policy initiative will be assigned at the management group scope in audit mode first.

## Consequences
- Provides enterprise-wide compliance visibility.
- Supports later NERC/CIP control mapping.
- Avoids disruptive enforcement during discovery.
- Can be moved from audit to enforce after remediation.
