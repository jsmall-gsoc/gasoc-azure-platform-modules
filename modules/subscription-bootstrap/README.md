# Subscription Bootstrap Module

This module establishes a NERC CIP-compliant foundation for a new subscription, including:

- Management groups and hierarchy
- Centralized logging (Log Analytics)
- Azure Policy framework
- Security defaults (firewalls, DDoS, etc.)
- RBAC role assignments
- Diagnostic settings aggregation
- Azure Backup vault setup
- Key Vault for secret management

## Usage

```hcl
module "subscription_bootstrap" {
  source = "../../modules/subscription-bootstrap"

  # Subscription configuration
  subscription_id      = data.azurerm_client_config.current.subscription_id
  tenant_id            = data.azurerm_client_config.current.tenant_id
  environment          = "prod"
  location             = "eastus"
  
  # NERC CIP configuration
  cip_criticality      = "Critical"  # Critical, Medium, Low
  enable_cip_policies  = true
  policy_enforcement   = "Audit"     # Audit or Deny
  
  # Logging configuration
  log_retention_days   = 90          # CIP-008 minimum
  
  # Tagging
  tags = {
    Environment        = "Prod"
    BusinessUnit       = "Infrastructure"
    CostCenter        = "Operations"
    DataClassification = "Internal"
    Criticality        = "High"
  }
}
```

## Outputs

```hcl
output "management_group_id" {
  description = "Root management group ID"
  value       = module.subscription_bootstrap.management_group_id
}

output "log_analytics_workspace_id" {
  description = "Central Log Analytics workspace ID"
  value       = module.subscription_bootstrap.log_analytics_workspace_id
}

output "recovery_services_vault_id" {
  description = "Backup vault ID"
  value       = module.subscription_bootstrap.recovery_services_vault_id
}
```

## What Gets Created

### Phase 1: Governance
- [ ] Management Group structure
- [ ] Policy definitions (NERC CIP)
- [ ] Policy initiatives
- [ ] Role definitions (custom)

### Phase 2: Logging & Monitoring
- [ ] Log Analytics workspace
- [ ] Storage account for audit logs
- [ ] Application Insights
- [ ] Azure Sentinel (SIEM)
- [ ] Alert rules & action groups

### Phase 3: Security
- [ ] Key Vault for secrets
- [ ] Key Vault for CMK (customer-managed encryption keys)
- [ ] Recovery Services Vault (backups)
- [ ] DDoS Protection plan

### Phase 4: RBAC
- [ ] Security Admin role assignment
- [ ] Terraform Contributor role assignment
- [ ] Application Contributor role assignment
- [ ] Audit & Compliance reader assignment

## Prerequisites

- Azure subscription (with Owner role)
- Service principal with Owner role on target subscription
- Entra ID admin access (for role definitions)
- Terraform ≥ 1.6.0

## Deployment Order

```bash
# 1. Apply bootstrap module
terraform apply -target=module.subscription_bootstrap

# 2. Wait for policy definitions to propagate (5-10 minutes)
sleep 300

# 3. Assign policies to subscription
terraform apply -target=module.policy_assignments

# 4. Verify compliance
az policy state summarize
```

## Configuration Examples

### Prod Subscription (NERC Compliant)
```hcl
module "prod_bootstrap" {
  source = "../../modules/subscription-bootstrap"
  
  environment         = "prod"
  cip_criticality     = "Critical"
  enable_cip_policies = true
  policy_enforcement  = "Deny"  # Strict enforcement
  log_retention_days  = 365     # 1 year retention
}
```

### Non-Prod Subscription (Less Restrictive)
```hcl
module "nonprod_bootstrap" {
  source = "../../modules/subscription-bootstrap"
  
  environment         = "nonprod"
  cip_criticality     = "Low"
  enable_cip_policies = true
  policy_enforcement  = "Audit"  # Log violations only
  log_retention_days  = 30       # 30 days retention
}
```

## Cost Estimation

| Resource | Est. Monthly Cost |
|---|---|
| Log Analytics (1 GB/day) | $30-50 |
| Key Vault | $0.34 + operations |
| Recovery Services Vault | $50 + storage |
| DDoS Protection (Standard) | $0 (included in vNet) |
| **Total** | **~$80-150** |

*Note: Costs scale with usage; adjust retention and storage policies to optimize.*

## Troubleshooting

### Policy Propagation Delay
Policies can take 10-30 minutes to take effect. Check status:
```bash
az policy state summarize --subscription <sub-id>
```

### Role Assignment Failure
Ensure service principal has Owner role on target subscription:
```bash
az role assignment create \
  --role Owner \
  --assignee-object-id <service-principal-object-id> \
  --scope /subscriptions/<subscription-id>
```

### Log Analytics Connection Failed
Verify network connectivity and firewall rules:
```bash
terraform plan -var enable_private_endpoint=false  # Disable private endpoint temporarily
```

## Post-Bootstrap Steps

After deployment, complete these steps:

1. **Verify Policies Applied**
   ```bash
   az policy assignment list --subscription <sub-id> --query "[?displayName contains 'CIP']"
   ```

2. **Test Compliance**
   ```bash
   # Attempt to create non-compliant resource (should fail if Deny mode)
   az storage account create --name test --resource-group myRG --kind StorageV2 --access-tier Hot
   ```

3. **Configure Alerts**
   - Log into Azure Portal
   - Navigate to Policy > Compliance
   - Create alerts for non-compliant resources

4. **Document Exemptions**
   - If any resources require exemption, create policy exemptions
   - Document rationale and expiration date

5. **Schedule Compliance Reviews**
   - Monthly: Review policy compliance dashboard
   - Quarterly: Full NERC CIP audit
   - Annually: Policy effectiveness review

## Maintenance

### Weekly
- [ ] Review failed policy assignments
- [ ] Check Log Analytics ingestion

### Monthly
- [ ] Generate compliance report
- [ ] Review and update policies
- [ ] Audit RBAC assignments

### Quarterly
- [ ] Conduct NERC CIP compliance assessment
- [ ] Update role definitions if needed
- [ ] Test backup/recovery procedures

---

## Files

- `main.tf` - Bootstrap resource definitions
- `variables.tf` - Configuration parameters
- `outputs.tf` - Exported values
- `bootstrap-config.yaml` - NERC CIP policy definitions (optional)
- `README.md` - This file
