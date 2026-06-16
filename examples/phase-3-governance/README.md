# Phase 3: Governance & Policy Assignment - NERC CIP Compliant Landing Zone

This phase establishes governance controls, policy enforcement, and RBAC for NERC CIP compliance.

## Architecture

```
Management Subscription
├── Management Groups (hierarchy by criticality)
├── Central Log Analytics
├── Azure Policy Definitions & Assignments
├── Azure Sentinel (SIEM)
├── Security Center
└── Blueprints/Role Definitions

Production Subscription(s)
├── Resource Groups (by workload)
├── Policy Enforcement (inherited from management)
├── RBAC Role Assignments
├── Diagnostic Settings → Central Logging
└── Compliance Monitoring

```

## Prerequisites

- Phase 1: Foundation resources deployed
- Phase 2: Hub-and-spoke networking established
- Service Principal with Owner role on target subscriptions
- Entra ID admin access

## Policy Scope

### CIP-002: Classification
- [ ] All resources tagged with `CIPClassification` (Critical/Medium/Low)
- [ ] Resource groups tagged with `BusinessUnit`, `CostCenter`
- [ ] Criticality-based policy targeting

### CIP-003: Security Management
- [ ] Azure Policy enforcement enabled
- [ ] Diagnostic settings mandatory
- [ ] Management locks on critical resources
- [ ] Change log audit enabled

### CIP-004: Personnel & Access Management
- [ ] Entra ID conditional access policies
- [ ] MFA enforcement for privileged roles
- [ ] Service principal authentication only (no keys)
- [ ] Role assignments follow least privilege

### CIP-005: System Security
- [ ] Network segmentation via NSGs (already done in Phase 2)
- [ ] Private endpoints for all services
- [ ] DDoS Protection on load balancers
- [ ] WAF on public endpoints

### CIP-006/014: Physical & Network Security
- [ ] Deny public IPs (policy)
- [ ] Require private endpoints
- [ ] Firewall rules centralized
- [ ] No direct RDP/SSH from internet

### CIP-007: System Security Management
- [ ] Vulnerability scanning enabled (Azure Defender)
- [ ] Update management configured
- [ ] Patch Tuesday automation
- [ ] Configuration baseline enforcement

### CIP-008: Incident Response
- [ ] Log Analytics retention ≥ 90 days
- [ ] Alert rules configured
- [ ] Action groups defined
- [ ] Azure Sentinel (SIEM) enabled

### CIP-009: Recovery Plans
- [ ] Azure Backup enabled on all VMs
- [ ] Recovery Services Vault with geo-replication
- [ ] Backup policies enforced (7-day minimum retention)
- [ ] RTO/RPO targets defined

### CIP-010: Configuration Management
- [ ] Terraform state locked & versioned
- [ ] Policy compliance baseline
- [ ] Change management via Git
- [ ] Remediation tasks tracked

### CIP-011: Information Protection
- [ ] Encryption at rest (BYOK)
- [ ] Encryption in transit (TLS 1.2+)
- [ ] Key Vault policies enforced
- [ ] Application-level encryption validation

### CIP-012: Supply Chain Risk
- [ ] Module versioning enforced
- [ ] Approved module registry only
- [ ] No unsigned modules
- [ ] Dependency scanning in CI/CD

### CIP-013: Transient Devices
- [ ] Managed disks only (no unmanaged)
- [ ] Disk encryption mandatory
- [ ] No USB/removable media enabled
- [ ] Device compliance policies (Intune)

---

## Deployment Instructions

### Step 1: Review Policy Assignments

Edit `terraform.tfvars`:

```hcl
environment              = "prod"
subscription_id          = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
tenant_id                = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
log_analytics_workspace_id = "/subscriptions/.../Microsoft.OperationalInsights/workspaces/law-prod-core"

# Policy enforcement mode: "Audit" or "Deny"
policy_enforcement_mode = "Audit"  # Start in Audit for 30 days

# NERC CIP scope
cip_enforcement_scope = "Critical"  # Critical, Medium, or All
```

### Step 2: Validate

```bash
terraform validate
terraform plan -var-file=terraform.tfvars -out=tfplan

# Review policy assignments before applying
cat tfplan | grep 'azurerm_policy_assignment'
```

### Step 3: Deploy

```bash
terraform apply tfplan
```

### Step 4: Monitor Compliance

```bash
# View policy compliance dashboard
az policy state summarize

# Export non-compliant resources
az policy state list --filter "IsCompliant eq false" --output json > non-compliant-resources.json

# Create remediation task
az policy remediation create \
  --name "remediate-cip-violations" \
  --policy-assignment "/subscriptions/.../Microsoft.Authorization/policyAssignments/CIP-010-Config-Mgmt" \
  --resource-group myRG \
  --resource-discovery-mode ReEvaluateCompliance
```

---

## Policy Enforcement Timeline

### T+0-30 Days: Audit Mode
```hcl
policy_enforcement_mode = "Audit"
```
- All policies log violations only
- Identify non-compliant resources
- Report findings to security team

### T+30-60 Days: Audit with Exemptions
```hcl
policy_enforcement_mode = "Deny"
exempted_resource_groups = ["dev-legacy", "test-old"]
```
- Policies deny non-compliant creation
- Allow exceptions for legacy resources
- Remediate existing violations

### T+60+ Days: Full Enforcement
```hcl
policy_enforcement_mode = "Deny"
exempted_resource_groups = []
```
- Zero non-compliant resources created
- Continuous monitoring
- Monthly compliance reporting

---

## Management Group Hierarchy

```
Tenant Root Group
├── Landing Zones (Production)
│   ├── Management Subscription (Policies, RBAC, Logging)
│   ├── Production Subscription (Platform Baseline)
│   │   ├── Power Grid Operations (Critical)
│   │   ├── SCADA Infrastructure (Critical)
│   │   └── Support Services (Medium)
│   └── Non-Production Subscription (Dev/Test)
└── Decommissioned (Archived)
```

Policy assignments cascade from top to bottom.

---

## RBAC Role Assignments

### Platform Engineers
- Role: `Terraform Contributor`
- Scope: Management subscription
- Permissions: Create/modify infrastructure

### Security Team
- Role: `Security Admin`
- Scope: All subscriptions
- Permissions: Policy assignments, Key Vault access, Compliance reviews

### Application Teams
- Role: `Application Contributor`
- Scope: Workload resource groups
- Permissions: Deploy to pre-provisioned resources only

### Audit/Compliance
- Role: `Compliance Reader`
- Scope: All subscriptions (read-only)
- Permissions: View policies, compliance state, audit logs

---

## Monitoring & Compliance Reporting

### Monthly Compliance Dashboard

```kusto
// Log Analytics query
PolicyEvaluationDetails
| where PolicyAssignmentName startswith "CIP-"
| where TimeGenerated > ago(30d)
| summarize 
  TotalResources = dcount(ResourceId),
  CompliantResources = dcount(ResourceId, IsCompliant == true),
  NonCompliantResources = dcount(ResourceId, IsCompliant == false)
  by PolicyAssignmentName
| extend CompliancePercentage = (CompliantResources / TotalResources) * 100
```

### Automated Alerts

```hcl
# Alert if compliance drops below 95%
resource "azurerm_monitor_metric_alert" "cip_compliance" {
  name                = "CIP-Compliance-Alert"
  description         = "Alert when CIP compliance below 95%"
  severity            = 2
  
  criteria {
    aggregation      = "Average"
    metric_name      = "CompliancePercentage"
    operator         = "LessThan"
    threshold        = 95
  }
}
```

---

## Troubleshooting

### Policy Assignment Failed

```bash
# Check policy definition status
az policy definition list --query "[?displayName contains 'CIP']"

# Verify policy assignment
az policy assignment list --query "[?displayName contains 'CIP-']"

# View policy evaluation errors
az policy state list --filter "IsCompliant eq false" --query "[0]" -o yaml
```

### Exemption Request Process

1. Document business justification
2. Identify resource requiring exemption
3. Submit PR with exemption request
4. Security team review
5. Merge with exemption duration (30/90 days)
6. Auto-expire after duration

```hcl
resource "azurerm_management_policy_rule_exemption" "example" {
  name                    = "legacy-storage-exemption"
  policy_assignment_id    = azurerm_policy_assignment.example.id
  resource_selectors {
    name = "legacy-storage"
    selectors {
      kind = "resourceType"
      in   = ["Microsoft.Storage/storageAccounts"]
    }
  }
  exemption_category = "Waived"
  expires_on         = "2026-07-16"  # 30 days
}
```

---

## Next Steps After Phase 3

1. **Continuous Monitoring**: Set up Azure Sentinel for threat detection
2. **Incident Response**: Test IR playbooks quarterly
3. **Policy Tuning**: Adjust policies based on 30-day audit results
4. **Documentation**: Create runbooks for common tasks
5. **Training**: Educate teams on NERC CIP requirements and policies

---

## Files in This Example

- `main.tf` - Main policy assignments
- `variables.tf` - Configuration parameters
- `outputs.tf` - Policy IDs and assignment details
- `locals.tf` - Local values and policy definitions
- `terraform.tfvars` - Example variables (copy and customize)
- `README.md` - This file
