# Developer Quick Reference - NERC CIP Terraform

Fast reference for common tasks in GASOC Azure Terraform Modules.

---

## ⚡ Quick Commands

### Setup
```bash
# Initialize workspace
terraform init

# Validate all modules
terraform validate
for dir in modules/*/; do (cd "$dir" && terraform validate) || exit 1; done

# Format all files
terraform fmt -recursive

# Check compliance before commit
./scripts/pre-commit-check.sh
```

### Quality Checks
```bash
# TFLint (code quality)
tflint --init
tflint --recursive --format json

# Checkov (security scanning)
checkov -d . --framework terraform --compact

# Combined check
terraform fmt -check -recursive && terraform validate && tflint --recursive && checkov -d .
```

### Deployment
```bash
# Plan deployment
terraform plan -var-file=terraform.tfvars -out=tfplan

# Apply changes
terraform apply tfplan

# Check state
terraform show
terraform state list
terraform state show 'module.example.azurerm_resource_group.this'
```

### Debugging
```bash
# Enable debug logging
TF_LOG=DEBUG terraform plan

# Check provider version
terraform providers

# Validate module syntax
terraform validate -json

# Show resource details
terraform console
> azurerm_resource_group.this.id
```

---

## 🔒 NERC CIP Checklist

Before submitting code:

```bash
# 1. ✅ Code Quality
terraform fmt -check -recursive
tflint --recursive

# 2. ✅ Security Scanning
checkov -d . --framework terraform --compact

# 3. ✅ Validation
terraform validate

# 4. ✅ Compliance Check
grep -r "hardcoded\|password\|secret\|key" *.tf  # Should return nothing
grep -r "public_ip" *.tf  # Should be restricted

# 5. ✅ Documentation
# - All variables have descriptions ✅
# - All outputs have descriptions ✅
# - README.md exists ✅
# - NERC_CIP_COMPLIANCE.md exists ✅
```

---

## 📝 Module Creation

### Quick Template
```hcl
# modules/my-module/variables.tf
variable "name" {
  description = "Resource name"
  type        = string
}

variable "cip_criticality" {
  description = "NERC CIP classification"
  type        = string
  default     = "Critical"
}

# modules/my-module/main.tf
resource "azurerm_resource_type" "this" {
  name = var.name
  
  tags = {
    CIPClassification = var.cip_criticality
  }
}

# modules/my-module/outputs.tf
output "id" {
  description = "Resource ID"
  value       = azurerm_resource_type.this.id
}
```

---

## 🔐 NERC CIP Patterns

### Encryption (CIP-011)
```hcl
# ✅ GOOD
encryption_at_rest_enabled = true
https_traffic_only_enabled = true
min_tls_version            = "TLS1_2"

# ❌ BAD
encryption_at_rest_enabled = false
```

### Authentication (CIP-004)
```hcl
# ✅ GOOD
identity {
  type = "SystemAssigned"  # or UserAssigned
}

# ❌ BAD
access_key        = "..."
connection_string = "..."
```

### Network Security (CIP-005)
```hcl
# ✅ GOOD
source_address_prefix       = "10.0.0.0/8"
destination_address_prefix  = "10.0.1.0/24"

# ❌ BAD
source_address_prefix       = "*"
destination_address_prefix  = "0.0.0.0/0"
```

### Logging (CIP-008)
```hcl
# ✅ GOOD
resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "diag"
  target_resource_id         = azurerm_resource_group.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  
  enabled_log { category = "Administrative" }
}

# ❌ BAD (missing diagnostic settings)
```

### Tags (CIP-002)
```hcl
# ✅ GOOD
tags = {
  CIPClassification = "Critical"
  Environment       = "Prod"
  ManagedBy         = "Terraform"
  Owner             = "Platform"
}

# ❌ BAD (missing CIP classification)
tags = {}
```

---

## 🐛 Troubleshooting

### Checkov: "Soft delete not enabled"
```hcl
# Add soft delete to Key Vault
resource "azurerm_key_vault" "this" {
  soft_delete_retention_days = 90  # ← Add this
  purge_protection_enabled   = true  # ← Add this
}
```

### TFLint: "Missing variable description"
```hcl
# Add description to all variables
variable "name" {
  description = "Clear, concise description"  # ← Add this
  type        = string
}
```

### Terraform: State locked
```bash
# Unlock state (emergency only)
terraform force-unlock <lock-id>

# View lock info
terraform state list
az storage blob lease break -c terraform-state -b prod.tfstate \
  --account-name <storage-account>
```

### Terraform: Module not found
```bash
# Re-init to fetch modules
terraform init

# Or with upgrade
terraform init -upgrade

# Check .terraform directory
ls -la .terraform/modules/
```

---

## 📦 Version Management

### Check versions
```bash
terraform --version
terraform providers

# Pin in required_providers
terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}
```

### Update modules
```bash
# Update module source to new version
source = "git::https://...?ref=v1.1.0"

# Reinit and plan to see changes
terraform init -upgrade
terraform plan
```

---

## 🔍 Policy Compliance

### Check policy status
```bash
# List all policy assignments
az policy assignment list \
  --resource-group myRG \
  --query "[?displayName contains 'CIP']"

# View compliance state
az policy state list \
  --resource-group myRG \
  --filter "IsCompliant eq false"

# Create remediation
az policy remediation create \
  --name "fix-violations" \
  --policy-assignment "/subscriptions/.../policyAssignments/CIP-011"
```

### Audit policy compliance
```kusto
// Log Analytics query
PolicyEvaluationDetails
| where PolicyAssignmentName contains "CIP"
| where IsCompliant == false
| summarize count() by PolicyAssignmentName, ResourceType
```

---

## 🔄 CI/CD Integration

### Azure DevOps Pipeline
```yaml
- task: TerraformCLI@0
  inputs:
    command: validate

- script: |
    tflint --init
    tflint --recursive --format json
  displayName: TFLint

- script: |
    checkov -d . --framework terraform --output json
  displayName: Checkov
```

### GitHub Actions
```yaml
- uses: hashicorp/setup-terraform@v2
  with:
    terraform_version: 1.6.0

- run: terraform validate

- run: |
    tflint --init
    tflint --recursive
```

---

## 📊 Useful Queries

### Count resources by type
```bash
terraform state list | cut -d'.' -f1 | sort | uniq -c
```

### Find all hardcoded values
```bash
grep -r "default\s*=" modules/ | grep -v "default\s*=\s*{" | grep -v "default\s*=\s*\"\"" | grep -v "default\s*=\s*\[\]"
```

### Check module dependencies
```bash
grep -r "source\s*=" examples/ | grep -v ".terraform"
```

### List all custom variables
```bash
find . -name "variables.tf" -exec grep "variable \"" {} + | cut -d'"' -f2 | sort | uniq
```

---

## 🎓 Learning Resources

### Essential Reading
- `NERC_CIP_COMPLIANCE.md` - CIP requirements
- `CONTRIBUTING.md` - Code standards
- `docs/standards/MODULE_TEMPLATE.md` - How to create modules
- `docs/standards/TFLINT_GUIDE.md` - Code quality
- `docs/standards/CHECKOV_GUIDE.md` - Security scanning

### External Resources
- [Terraform Docs](https://www.terraform.io/docs/)
- [Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [Azure Best Practices](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/)
- [NERC CIP Standards](https://www.nerc.net/pa/standards/)

---

## 🆘 Common Issues & Solutions

| Issue | Solution |
|---|---|
| "Provider version not available" | Run `terraform init -upgrade` |
| "Module not found" | Check git URL and ref version |
| "State lock timeout" | Use `terraform force-unlock` (emergency only) |
| "Plan shows unexpected changes" | Check variable values and refresh: `terraform refresh` |
| "Checkov failing on valid config" | Add `checkov:skip=CKV_*:reason` comment |
| "TFLint rule too strict" | Disable in `.tflint.hcl` with documentation |

---

## ⚙️ Configuration Files

### `.tflint.hcl`
```hcl
plugin "azurerm" {
  enabled = true
}
```

### `.checkov.yaml`
```yaml
framework: [terraform]
check: ["HIGH", "CRITICAL"]
skip-download: false
```

### `.gitignore`
```
.terraform/
*.tfstate*
*.tfvars
.env
crash.log
```

---

## 🚀 Deployment Workflow

```
1. Create feature branch
   ↓
2. Make changes following MODULE_TEMPLATE
   ↓
3. Run: fmt + validate + tflint + checkov
   ↓
4. Commit with NERC CIP reference
   ↓
5. Push and create PR
   ↓
6. Verify CI/CD passes
   ↓
7. Get 2 approvals
   ↓
8. Merge to develop
   ↓
9. Test in non-prod
   ↓
10. Tag release (v1.X.X)
    ↓
11. Deploy to production
```

---

**Last Updated**: 2026-06-16
**Version**: 1.0.0
