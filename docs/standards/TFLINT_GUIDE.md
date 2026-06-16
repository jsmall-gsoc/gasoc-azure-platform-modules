# TFLint Configuration - NERC CIP Compliance

This tflint configuration enforces Azure best practices and NERC CIP compliance patterns.

## Installation

```bash
# Install tflint
curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# Install Azure plugin
tflint --init

# Or with asdf
asdf plugin add tflint
asdf install tflint latest
```

## Configuration

Copy this file to your Terraform root:

```bash
cp .tflint.hcl ../../..
```

## Running TFLint

```bash
# Check all files
tflint --recursive --format json

# Check single directory
tflint modules/key-vault/

# Fix automatically (some issues)
tflint --fix

# Generate report
tflint --format json > tflint-report.json
```

## CI/CD Integration

```yaml
# .azure-pipelines/tflint.yml
trigger:
  - main
  - develop

pool:
  vmImage: ubuntu-latest

steps:
  - task: TerraformCLI@0
    inputs:
      command: validate
      workingDirectory: $(Build.SourcesDirectory)

  - script: |
      curl https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash
      tflint --init
      tflint --recursive --format json > $(Build.ArtifactStagingDirectory)/tflint-report.json
    displayName: Run TFLint

  - task: PublishBuildArtifacts@1
    inputs:
      PathtoPublish: $(Build.ArtifactStagingDirectory)
      ArtifactName: tflint-reports
```

## Rules Enforced

### NERC CIP-004: Access Management
- ✓ `azurerm_resource_group_name_restriction` - Naming convention
- ✓ `azurerm_variable_description_required` - Document all inputs

### NERC CIP-005/006: Security Management
- ✓ `azurerm_key_vault_enable_purge_protection` - Prevent accidental deletion
- ✓ `azurerm_key_vault_enable_soft_delete` - Enable recovery
- ✓ `azurerm_storage_account_https_only` - TLS requirement
- ✓ `azurerm_storage_account_min_tls_version` - Enforce TLS 1.2+

### NERC CIP-007: System Security
- ✓ `azurerm_managed_disk_encryption` - Disk encryption required
- ✓ `azurerm_network_security_group_rules` - Restrictive NSG defaults
- ✓ `azurerm_network_security_group_deny_all_inbound` - Deny by default

### NERC CIP-008: Incident Response
- ✓ `azurerm_log_analytics_retention` - Minimum 90 days
- ✓ `azurerm_diagnostic_settings_required` - Log all resources

### NERC CIP-010: Configuration Management
- ✓ `azurerm_output_description_required` - Document outputs
- ✓ `azurerm_backend_azure_state_lock` - Enable state locking
- ✓ No hardcoded values in code

### NERC CIP-011: Information Protection
- ✓ `azurerm_encryption_at_rest_required` - Always encrypt
- ✓ `azurerm_tls_minimum_version` - TLS 1.2+
- ✓ `azurerm_key_vault_managed_hsm` - HSM for critical keys

### NERC CIP-013: Transient Devices
- ✓ `azurerm_managed_disk_only` - No unmanaged disks
- ✓ `azurerm_disk_encryption` - Disk encryption mandatory

## Common Issues & Fixes

### Issue: "Missing variable description"
```hcl
# ❌ BAD
variable "name" {
  type = string
}

# ✅ GOOD
variable "name" {
  description = "Resource name (CIP-002 classification required)"
  type        = string
}
```

### Issue: "Storage account without HTTPS only"
```hcl
# ❌ BAD
resource "azurerm_storage_account" "this" {
  name              = "mysa"
  resource_group_name = azurerm_resource_group.this.name
  # Missing https_traffic_only_enabled
}

# ✅ GOOD
resource "azurerm_storage_account" "this" {
  name                     = "mysa"
  resource_group_name      = azurerm_resource_group.this.name
  https_traffic_only_enabled = true
  min_tls_version          = "TLS1_2"
}
```

### Issue: "Key Vault without soft delete"
```hcl
# ❌ BAD
resource "azurerm_key_vault" "this" {
  name = "mykvault"
}

# ✅ GOOD
resource "azurerm_key_vault" "this" {
  name                       = "mykvault"
  soft_delete_retention_days = 90  # Required for recovery
  purge_protection_enabled   = true  # Prevent permanent deletion
}
```

## Disabling Rules

Only disable with documented justification:

```hcl
# Example: Disable a rule with rationale
resource "azurerm_storage_account" "legacy" {
  # tflint-ignore: azurerm_storage_account_https_only,
  # Justification: Legacy system requires HTTP for compatibility (CIP-005 exemption #123)
  https_traffic_only_enabled = false
}
```

Document exemptions:

```markdown
# Exemption #123: Legacy Storage Account HTTPS
- Date: 2026-06-16
- Resource: storage-account-legacy
- Rule: azurerm_storage_account_https_only
- Duration: 90 days (expires 2026-09-14)
- Justification: Old system cannot connect via HTTPS
- Remediation: Planned system upgrade in Q3 2026
- Owner: Legacy App Team
- Approval: Security Team
```

---

## Advanced Configuration

### Custom Rules

Create custom rules in `.tflint-custom.hcl`:

```hcl
rule "azurerm_no_hardcoded_passwords" {
  enabled = true

  trigger "variable" {
    filter  = "attributes.type == string"
    content = "default =~ /password|secret|key/"

    message = "Hardcoded passwords/secrets detected (CIP-011)"
    level   = "error"
  }
}
```

### Rule Sets

Group rules by CIP requirement:

```hcl
# In .tflint.hcl
ruleset "cip_004" {
  rules = [
    "azurerm_resource_group_name_restriction",
    "azurerm_variable_description_required",
  ]
}

ruleset "cip_005" {
  rules = [
    "azurerm_key_vault_enable_purge_protection",
    "azurerm_storage_account_https_only",
  ]
}
```

### Pre-commit Hook

Automatically run tflint before commits:

```bash
# Install pre-commit
pip install pre-commit

# Copy hook configuration
cp .pre-commit-config.yaml ..

# Install hook
pre-commit install
```

File: `.pre-commit-config.yaml`
```yaml
repos:
  - repo: https://github.com/terraform-linters/tflint
    rev: v0.50.0
    hooks:
      - id: tflint
        args: [--format, json]
```

---

## Integration with Checkov

Use both tools together:

```bash
#!/bin/bash
# run-quality-checks.sh

echo "=== Running TFLint (code quality) ==="
tflint --recursive --format json > tflint-report.json

echo "=== Running Checkov (security/compliance) ==="
checkov -d . --framework terraform --output json > checkov-report.json

echo "=== Reports generated ==="
echo "tflint-report.json"
echo "checkov-report.json"
```

---

## Resources

- [TFLint Documentation](https://github.com/terraform-linters/tflint/tree/master/docs)
- [Terraform Best Practices](https://terraform.io/language/values)
- [Azure Security Benchmark](https://learn.microsoft.com/en-us/security/benchmark/azure/)
- [NERC CIP Standards](https://www.nerc.net/pages/standards/standards-in-development.aspx)
