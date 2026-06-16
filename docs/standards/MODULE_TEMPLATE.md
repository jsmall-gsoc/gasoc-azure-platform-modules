# Module Development Template - NERC CIP Compliant

Use this template when creating new modules for the GASOC Azure Terraform Modules library.

## File Structure

```
new-module/
├── main.tf                      # Primary resource definitions
├── variables.tf                 # Input variables (required)
├── outputs.tf                   # Output values (required)
├── locals.tf                    # (Optional) Local values
├── README.md                    # (Required) User documentation
├── NERC_CIP_COMPLIANCE.md      # (Required) Compliance mapping
└── examples/
    └── basic/
        ├── main.tf
        ├── variables.tf
        └── terraform.tfvars
```

## Step 1: Create variables.tf

```hcl
# modules/new-module/variables.tf

variable "resource_name" {
  description = "Name of the resource"
  type        = string

  validation {
    condition     = length(var.resource_name) > 0 && length(var.resource_name) <= 24
    error_message = "Resource name must be 1-24 characters"
  }
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment: prod, nonprod, dev"
  type        = string

  validation {
    condition     = contains(["prod", "nonprod", "dev"], var.environment)
    error_message = "Must be prod, nonprod, or dev"
  }
}

variable "cip_criticality" {
  description = "NERC CIP Criticality level: Critical, Medium, Low (CIP-002)"
  type        = string
  default     = "Critical"

  validation {
    condition     = contains(["Critical", "Medium", "Low"], var.cip_criticality)
    error_message = "Must be Critical, Medium, or Low"
  }
}

variable "enable_cip_controls" {
  description = "Enable additional NERC CIP compliance controls"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Standard Azure resource tags"
  type        = map(string)
  default     = {}
}
```

## Step 2: Create main.tf

```hcl
# modules/new-module/main.tf

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

locals {
  common_tags = merge(
    var.tags,
    {
      ManagedBy       = "Terraform"
      Module          = "new-module"
      Environment     = var.environment
      CIPClassification = var.cip_criticality
      ComplianceScope = "NERC-CIP"
      CreatedDate     = timestamp()
    }
  )

  # Example: Add CIP-specific configuration
  cip_controls_enabled = var.enable_cip_controls
}

# Example resource with NERC CIP controls
resource "azurerm_resource_type" "this" {
  name                = var.resource_name
  resource_group_name = var.resource_group_name
  location            = var.location

  # CIP-011: Encryption at rest
  encryption {
    enabled = local.cip_controls_enabled
  }

  # CIP-008: Diagnostic logging
  dynamic "diagnostic_settings" {
    for_each = local.cip_controls_enabled ? [1] : []
    content {
      log_level = "Info"
    }
  }

  # CIP-003: Management locks on critical resources
  lifecycle {
    prevent_destroy = var.cip_criticality == "Critical"
  }

  tags = local.common_tags
}
```

## Step 3: Create outputs.tf

```hcl
# modules/new-module/outputs.tf

output "id" {
  description = "Resource ID"
  value       = azurerm_resource_type.this.id
}

output "name" {
  description = "Resource name"
  value       = azurerm_resource_type.this.name
}

output "location" {
  description = "Resource location"
  value       = azurerm_resource_type.this.location
}
```

## Step 4: Create README.md

```markdown
# New Module

Description of what this module does.

## NERC CIP Compliance

This module addresses the following NERC CIP requirements:

| CIP Control | Requirement | Implementation |
|---|---|---|
| CIP-002 | Resource classification | Tags: CIPClassification, BusinessUnit |
| CIP-011 | Encryption at rest | Azure-managed encryption enabled by default |
| CIP-008 | Diagnostic logging | Integrated with central Log Analytics |

## Usage

```hcl
module "example" {
  source = "git::https://dev.azure.com/org/project/_git/gasoc-azure-terraform-modules//modules/new-module?ref=v1.0.0"

  resource_name       = "my-resource"
  resource_group_name = azurerm_resource_group.this.name
  location            = "eastus"
  environment         = "prod"
  cip_criticality     = "Critical"

  tags = {
    Owner        = "Platform Team"
    CostCenter   = "Infrastructure"
  }
}
```

## Variables

### Required

- `resource_name` (string): Name of the resource
- `resource_group_name` (string): Resource group name
- `location` (string): Azure region

### Optional

- `cip_criticality` (string): NERC CIP classification level (default: "Critical")
- `enable_cip_controls` (bool): Enable CIP controls (default: true)
- `tags` (map): Additional tags

## Outputs

- `id`: Resource ID
- `name`: Resource name

## Examples

See [examples/](./examples/) directory for complete examples.

## Compliance Notes

- Encryption enabled by default (CIP-011)
- Managed identity required (CIP-004)
- Diagnostic logging mandatory (CIP-008)
```

## Step 5: Create NERC_CIP_COMPLIANCE.md

```markdown
# NERC CIP Compliance - New Module

## Controls Implemented

### CIP-002: Classification
- All resources tagged with CIP classification
- Business unit and cost center tracking
- **Status**: ✅ Implemented

### CIP-011: Information Protection
- Encryption at rest enabled by default
- Managed encryption keys (no customer-managed required for this service)
- **Status**: ✅ Implemented

### CIP-008: Incident Response
- Diagnostic settings integrated
- Logs sent to centralized Log Analytics
- Retention: 90+ days
- **Status**: ✅ Implemented

### CIP-003: Security Management
- Management locks on critical resources
- Change tracking via Terraform state
- **Status**: ✅ Implemented

## Security Validations

```hcl
# All inputs validated
variable "cip_criticality" {
  validation {
    condition     = contains(["Critical", "Medium", "Low"], var.cip_criticality)
    error_message = "Invalid CIP classification"
  }
}

# Encryption enforced
encryption {
  enabled = true  # Cannot be disabled
}

# Immutability for critical resources
lifecycle {
  prevent_destroy = var.cip_criticality == "Critical"
}
```

## Testing

Verify compliance with:

```bash
# TFLint
tflint modules/new-module

# Checkov
checkov -d modules/new-module --framework terraform

# Manual validation
terraform plan -var-file=test.tfvars
```

## Non-Compliant Patterns

Do NOT use these patterns:

```hcl
# ❌ BAD: Encryption disabled
encryption {
  enabled = false
}

# ❌ BAD: No tags
resource "azurerm_resource_type" "this" {
  # Missing tags
}

# ❌ BAD: Hardcoded values
variable "api_key" {
  default = "super-secret-key"  # Never!
}
```

## Exemptions

If compliance cannot be met, document exemption:

```hcl
# CIP-011 Exemption #123: Service does not support encryption
# Duration: 90 days (expires 2026-09-16)
# Owner: Platform Team
# Justification: Legacy system requirement
```
```

## Step 6: Create Example

```hcl
# modules/new-module/examples/basic/main.tf

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  environment = "prod"
  location    = "eastus"

  common_tags = {
    Environment        = local.environment
    Application        = "PlatformCore"
    Owner              = "CloudEngineering"
    CostCenter         = "Operations"
    ManagedBy          = "Terraform"
    DataClassification = "Internal"
    Criticality        = "High"
  }
}

resource "azurerm_resource_group" "this" {
  name     = "rg-${local.environment}-eus"
  location = local.location
  tags     = local.common_tags
}

module "new_module" {
  source = "../.."

  resource_name       = "resource-${local.environment}"
  resource_group_name = azurerm_resource_group.this.name
  location            = local.location
  environment         = local.environment
  cip_criticality     = "Critical"

  tags = local.common_tags
}

output "module_id" {
  value = module.new_module.id
}
```

## Step 7: Module Checklist

Before submitting PR:

- [ ] All variables have descriptions
- [ ] All outputs have descriptions
- [ ] NERC CIP compliance documented
- [ ] Encryption enabled by default
- [ ] Managed identity required (no keys)
- [ ] Diagnostic settings integrated
- [ ] Tagging strategy implemented
- [ ] README.md complete
- [ ] Example provided and working
- [ ] `terraform fmt` passed
- [ ] `terraform validate` passed
- [ ] `tflint` passed
- [ ] `checkov` passed
- [ ] No hardcoded values
- [ ] No secrets in code

## PR Submission

1. Create branch: `git checkout -b feature/new-module`
2. Implement module following this template
3. Run quality checks:
   ```bash
   terraform fmt -check -recursive
   terraform validate
   tflint --recursive
   checkov -d . --framework terraform --compact
   ```
4. Submit PR with description
5. Reference NERC CIP requirements addressed
6. Get approval from 2 reviewers
7. Merge to develop branch

---

## Resources

- [Module Template](./MODULE_TEMPLATE.md) - This file
- [NERC CIP Compliance Guide](../NERC_CIP_COMPLIANCE.md)
- [Contributing Guidelines](../../CONTRIBUTING.md)
- [Azure Terraform Best Practices](https://learn.microsoft.com/en-us/azure/developer/terraform/)
