# Policy Definitions for NERC CIP Compliance

This directory contains Azure Policy definitions and assignments that enforce NERC CIP-002 through CIP-014 requirements.

## Policy Files

- `cip-002-003-classification-and-security.json` - CIP-002/003 (Classification + Security Management)
- `cip-004-005-access-and-systems-security.json` - CIP-004/005 (Personnel Access + System Security)
- `cip-006-014-network-and-physical-security.json` - CIP-006/014 (Network + Physical Security)
- `cip-007-system-security-management.json` - CIP-007 (System Security)
- `cip-008-incident-response.json` - CIP-008 (Incident Response)
- `cip-009-recovery-plans.json` - CIP-009 (Recovery & Disaster Recovery)
- `cip-010-configuration-management.json` - CIP-010 (Configuration Management)
- `cip-011-information-protection.json` - CIP-011 (Encryption & Data Protection)
- `cip-012-supply-chain.json` - CIP-012 (Supply Chain Risk)
- `cip-013-transient-devices.json` - CIP-013 (Physical Media Security)

## Usage

Deploy all policies in order:

```bash
cd examples/phase-3-governance
terraform apply -target=module.cip_policies
```

## Policy Enforcement Modes

- **Audit**: Log non-compliant resources (discovery phase)
- **Deny**: Block non-compliant resource creation (enforcement phase)
- **Disabled**: For testing before activation

## Policy Effect Timeline

### Month 1-2: Audit Mode
- All policies in "Audit" mode
- Identify non-compliant resources
- Adjust policies based on findings

### Month 3-4: Warn Mode
- Policies in "Deny" with exemption mechanism
- Allow documented exceptions
- Remediate pre-existing resources

### Month 5+: Enforce Mode
- All policies in "Deny" mode
- Zero non-compliant resources created
- Continuous monitoring

## Monitoring Policy Compliance

View policy compliance in Azure Portal:
- Policy > Compliance
- Filter by "NERC CIP"
- Review non-compliant resources
- Create remediation tasks

Via Azure CLI:

```bash
az policy state list --resource-group myRG --filter "IsCompliant eq false"
```

Via Log Analytics:

```kusto
PolicyEvaluationDetails
| where PolicyAssignmentName contains "CIP"
| where IsCompliant == false
| summarize count() by PolicyAssignmentName, ResourceType
```

## Testing Policies

Before production deployment:

```bash
# Deploy to non-prod subscription
terraform plan -var subscription_id=<non-prod-sub>

# Test policy assignment (Audit mode)
terraform apply -var-file=audit.tfvars

# Attempt to create non-compliant resource (should log, not fail)
az storage account create --name test --resource-group myRG --kind StorageV2 --access-tier Hot

# Check audit logs
az activity-log list --resource-group myRG --query "[?operationName.value=='Microsoft.Authorization/policyAssignments/audit/action']"
```

## Policy Assignment Best Practices

1. **Scope Carefully**: Assign only to subscriptions/resource groups that need compliance
2. **Document Exceptions**: Exemptions require justification and approval
3. **Monitor Continuously**: Review policy compliance monthly
4. **Test Before Enforcement**: Always run in Audit mode first
5. **Version Policies**: Track policy changes in git

## Custom Policy Extension

To add additional CIP controls:

1. Create policy definition in JSON
2. Add to appropriate CIP-XXX file
3. Create Terraform resource in `variables.tf`
4. Add to policy initiative
5. Test in non-prod environment
6. Update this README

Example policy structure:

```json
{
  "type": "Microsoft.Authorization/policyDefinitions",
  "apiVersion": "2021-06-01",
  "name": "deny-unencrypted-storage-accounts",
  "properties": {
    "displayName": "Deny unencrypted storage accounts (CIP-011)",
    "policyType": "Custom",
    "mode": "Indexed",
    "description": "Ensures all storage accounts have encryption enabled",
    "metadata": {
      "category": "NERC CIP-011",
      "version": "1.0.0"
    },
    "parameters": {
      "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Audit or Deny"
        },
        "allowedValues": ["Audit", "Deny"],
        "defaultValue": "Audit"
      }
    },
    "policyRule": {
      "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "Microsoft.Storage/storageAccounts"
          },
          {
            "field": "Microsoft.Storage/storageAccounts/encryption.services.blob.enabled",
            "notEquals": true
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]"
      }
    }
  }
}
```
