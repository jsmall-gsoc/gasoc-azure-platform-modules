# NERC CIP Compliance Requirements Mapping

## Overview

This document maps NERC Critical Infrastructure Protection standards (CIP-002 through CIP-014) to Azure infrastructure and Terraform module controls.

## NERC CIP Requirements & Azure/Terraform Implementation

### CIP-002: BES Cyber System Classification

**Requirement**: Identify and classify all Bulk Electric System (BES) cyber systems.

**Azure/Terraform Controls**:
- [ ] Resource tagging with classification level
- [ ] Naming convention enforcement (via Policy)
- [ ] Environment designation (Production/Non-Prod)
- [ ] Business criticality tags

**Module Implementation**:
```hcl
variable "criticality" {
  description = "Criticality level: Critical, Medium, Low"
  type        = string
  validation {
    condition     = contains(["Critical", "Medium", "Low"], var.criticality)
    error_message = "Must be Critical, Medium, or Low."
  }
}

locals {
  cip_tags = {
    CIPClassification = var.criticality
    ComplianceScope   = "NERC-CIP"
    DataClassification = "Confidential"
  }
}
```

---

### CIP-003: Security Management Controls

**Requirement**: Develop and implement security policies and procedures for cyber security.

**Azure/Terraform Controls**:
- [ ] Azure Policy for enforce security baselines
- [ ] Diagnostic settings (all resources log to centralized Log Analytics)
- [ ] Configuration governance via Terraform state
- [ ] Change management via Git with approval workflows

**Module Implementation**:
```hcl
resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = "${var.resource_name}-diag"
  target_resource_id         = azurerm_resource_group.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "Administrative"
  }
}

resource "azurerm_management_lock" "this" {
  name       = "CIP-003-lock"
  scope      = azurerm_resource_group.this.id
  lock_level = "CanNotDelete"
}
```

---

### CIP-004: Personnel and Access Management

**Requirement**: Implement and maintain controls for personnel and user account management.

**Azure/Terraform Controls**:
- [ ] RBAC with least-privilege roles
- [ ] Entra ID conditional access policies
- [ ] MFA enforcement via policy
- [ ] Service principal with managed identity
- [ ] No shared credentials or keys

**Module Implementation**:
```hcl
resource "azurerm_role_assignment" "this" {
  scope              = azurerm_resource_group.this.id
  role_definition_name = "Contributor"  # Should be more restrictive
  principal_id       = var.managed_identity_principal_id

  lifecycle {
    precondition {
      condition     = var.enable_rbac_validation
      error_message = "RBAC configuration validation failed"
    }
  }
}

# Enforce no key-based auth
resource "azurerm_key_vault_access_policy" "deny_keys" {
  vault_name          = var.key_vault_name
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = var.deny_principal_id

  key_permissions = []  # Explicitly deny
}
```

---

### CIP-005: Systems Security Management

**Requirement**: Manage the security of the information system and its network connections.

**Azure/Terraform Controls**:
- [ ] Network segmentation via NSGs and Firewalls
- [ ] DDoS protection enabled (Standard or higher)
- [ ] Private endpoints for critical services
- [ ] Azure Firewall rules for ingress/egress
- [ ] TLS 1.3 enforced (where supported)

**Module Implementation**:
```hcl
resource "azurerm_network_security_group" "this" {
  name                = var.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_ddos_protection_plan" "this" {
  count               = var.enable_ddos_protection ? 1 : 0
  name                = "${var.environment}-ddos"
  location            = var.location
  resource_group_name = var.resource_group_name
}
```

---

### CIP-006: Physical and Environmental Protection

**Requirement**: Protect physical access to BES cyber systems.

**Azure/Terraform Controls**:
- [ ] Azure regions in geographically protected datacenters
- [ ] Private Link for network isolation
- [ ] No public endpoints on critical resources
- [ ] Managed disk encryption required
- [ ] Public IP restrictions via policy

**Module Implementation**:
```hcl
resource "azurerm_private_endpoint" "this" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = "${var.resource_name}-pep"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.resource_name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
  }
}

resource "azurerm_managed_disk" "this" {
  encryption_settings {
    enabled = true
  }

  storage_account_type = "Premium_LRS"  # High availability
}
```

---

### CIP-007: Systems Security Management

**Requirement**: Implement controls to ensure proper security configuration and management of information systems.

**Azure/Terraform Controls**:
- [ ] Azure Update Management for patching
- [ ] Web Application Firewall (WAF) enabled
- [ ] Vulnerability scanning (Azure Defender, Qualys)
- [ ] Configuration baseline enforcement
- [ ] Antimalware/Endpoint protection

**Module Implementation**:
```hcl
resource "azurerm_web_application_firewall_policy" "this" {
  count               = var.enable_waf ? 1 : 0
  name                = "${var.environment}-waf"
  location            = var.location
  resource_group_name = var.resource_group_name
  mode                = "Prevention"  # Not Detection

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
}

resource "azurerm_security_center_subscription_pricing" "this" {
  tier          = "Standard"  # Required for continuous vulnerability scanning
  resource_type = "VirtualMachines"
}
```

---

### CIP-008: Incident Reporting and Response Planning

**Requirement**: Implement incident response and reporting procedures.

**Azure/Terraform Controls**:
- [ ] Centralized logging via Log Analytics
- [ ] Alert rules configured for security events
- [ ] Action groups for incident notification
- [ ] Azure Sentinel for SIEM/incident detection
- [ ] Audit trail maintenance (90+ days retention)

**Module Implementation**:
```hcl
resource "azurerm_monitor_action_group" "this" {
  name                = "${var.environment}-incident-response"
  resource_group_name = var.resource_group_name
  short_name          = "IncResp"

  email_receiver {
    name          = "SecurityTeam"
    email_address = var.incident_response_email
  }
}

resource "azurerm_monitor_metric_alert" "this" {
  name                = "SecurityEventAlert"
  resource_group_name = var.resource_group_name
  scopes              = [var.log_analytics_workspace_id]
  description         = "Alert on NERC CIP security events"
  severity            = 2

  criteria {
    metric_name      = "SecurityEventCount"
    operator         = "GreaterThan"
    threshold        = 10
    aggregation      = "Total"
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}
```

---

### CIP-009: Recovery Plans

**Requirement**: Develop, maintain, and test recovery and restoration procedures.

**Azure/Terraform Controls**:
- [ ] Azure Backup enabled for critical resources
- [ ] Recovery Services Vault with geo-replication
- [ ] Backup policies with retention > 30 days
- [ ] Disaster recovery replication (cross-region)
- [ ] RTO/RPO targets defined in policy

**Module Implementation**:
```hcl
resource "azurerm_recovery_services_vault" "this" {
  name                = "${var.environment}-rsv"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "Standard"
  soft_delete_enabled = true
  immutability_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_backup_policy_vm" "this" {
  name                = "DailyBackup"
  resource_group_name = var.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.this.name

  backup {
    frequency = "Daily"
    time      = "03:00"  # Off-peak
  }

  retention_daily {
    count = 30
  }

  retention_yearly {
    count    = 1
    months   = ["January"]
  }
}
```

---

### CIP-010: Configuration and Vulnerability Management

**Requirement**: Identify, prioritize, and remediate cyber security vulnerabilities.

**Azure/Terraform Controls**:
- [ ] Terraform state versioning and locking
- [ ] Configuration baseline in Azure Policy
- [ ] Compliance scanning (Azure Policy, Defender)
- [ ] Vulnerability assessment (Azure Defender for SQL, App Service)
- [ ] Change log tracking (git + Terraform)

**Module Implementation**:
```hcl
terraform {
  required_version = ">= 1.6.0"

  backend "azurerm" {
    # Enforce versioning
    use_oidc                      = true
    tenant_id                     = var.tenant_id
    subscription_id               = var.subscription_id
    container_name                = "terraform-state"
    key                           = "prod.tfstate"
    use_msi                       = false  # Managed identity
  }
}

resource "azurerm_security_center_server_vulnerability_assessment" "this" {
  virtual_machine_id = var.vm_id
}

resource "azurerm_policy_assignment" "cip_010_vulnerability_management" {
  name              = "CIP-010-VulnMgmt"
  scope             = var.subscription_id
  policy_definition_id = "/subscriptions/.../Microsoft.Authorization/policyDefinitions/..."

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}
```

---

### CIP-011: Information Protection

**Requirement**: Protect information by limiting physical access and applying appropriate encryption.

**Azure/Terraform Controls**:
- [ ] Encryption at rest (EDE for SQL, BYOK for storage)
- [ ] Encryption in transit (TLS 1.2+, HTTPS only)
- [ ] Key management via Key Vault
- [ ] Transparent Database Encryption (TDE)
- [ ] Application-level encryption where needed

**Module Implementation**:
```hcl
resource "azurerm_key_vault" "this" {
  name                       = var.key_vault_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  purge_protection_enabled   = true
  soft_delete_retention_days = 90

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.this.principal_id

    key_permissions    = ["Get", "UnwrapKey", "WrapKey"]
    secret_permissions = ["Get"]
  }
}

resource "azurerm_storage_account" "this" {
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_mssql_server" "this" {
  transparent_data_encryption_enabled = true
}
```

---

### CIP-012: Supply Chain Risk Management

**Requirement**: Manage the risks from software, hardware, and services that could adversely affect security.

**Azure/Terraform Controls**:
- [ ] Module versioning and tagging
- [ ] Approved module registry (private)
- [ ] Module attestation/signing
- [ ] Dependency scanning for vulnerabilities
- [ ] Azure marketplace validated vendors only

**Module Implementation**:
```hcl
variable "approved_module_version" {
  description = "Only approved, signed module versions"
  type        = string
  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.approved_module_version))
    error_message = "Must use semantic versioning (v1.0.0)"
  }
}

# Use only from approved registry
module "approved_networking" {
  source = "git::https://dev.azure.com/org/project/_git/approved-modules//networking?ref=v1.0.0"
  # NOT from untrusted sources
}
```

---

### CIP-013: Physical Security - Transient Devices

**Requirement**: Protect against unauthorized access to physical devices and removable media.

**Azure/Terraform Controls**:
- [ ] No local storage allowed (use managed disks)
- [ ] Managed disks with encryption required
- [ ] No removable media in infrastructure code
- [ ] USB device policies via Entra ID
- [ ] Device compliance policies (Intune)

**Module Implementation**:
```hcl
resource "azurerm_virtual_machine" "this" {
  os_profile {
    # Do NOT allow local admin access
    admin_username = "NotAllowed"
  }

  storage_os_disk {
    managed_disk_type = "Premium_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  # No unmanaged disks
  lifecycle {
    precondition {
      condition     = var.use_managed_disks
      error_message = "Only managed disks permitted (CIP-013)"
    }
  }
}

# Device compliance
resource "azurerm_device_configuration_policy" "usb_restriction" {
  display_name = "Block USB Devices"
  platform     = "windows"

  settings {
    removable_storage_blocked = true
  }
}
```

---

### CIP-014: Physical Security - High and Medium Impact

**Requirement**: Protect high and medium impact BES cyber systems with physical security controls.

**Azure/Terraform Controls**:
- [ ] Deny public IP assignment (via policy)
- [ ] Restrict access to Azure resources to approved networks
- [ ] DDoS protection enabled
- [ ] WAF enabled for public endpoints
- [ ] Network segmentation enforced

**Module Implementation**:
```hcl
resource "azurerm_policy_assignment" "cip_014_no_public_ip" {
  name              = "CIP-014-NoPublicIP"
  scope             = var.subscription_id
  policy_definition_id = "/subscriptions/.../Microsoft.Authorization/policyDefinitions/..."
  enforcement_mode   = "Default"
  
  description = "CIP-014 Compliance: Prevent public IP assignment"
}

resource "azurerm_firewall" "this" {
  count               = var.criticality == "Critical" ? 1 : 0
  name                = "${var.environment}-firewall"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_Hub"
  sku_tier            = "Premium"  # Required for advanced protection

  threat_intel_mode = "Alert"  # Or Deny for strict enforcement
}

resource "azurerm_firewall_nat_rule_collection" "this" {
  action              = "Dnat"
  name                = "RuleCollection1"
  priority            = 100
  resource_group_name = var.resource_group_name

  rule {
    name                = "rule1"
    source_addresses    = ["*"]
    source_ports        = ["*"]
    destination_ports   = ["80", "443"]
    destination_address = [var.load_balancer_ip]
    translated_address  = var.backend_pool_address
    translated_port     = "8080"
    protocols           = ["TCP"]
  }
}
```

---

## Compliance Validation Checklist

### Before Deployment

- [ ] All resources tagged with CIP classification
- [ ] Diagnostic settings configured
- [ ] RBAC roles validated (least privilege)
- [ ] Network segmentation verified
- [ ] Encryption enabled (at rest & in transit)
- [ ] Backup/recovery plan documented
- [ ] Incident response contacts configured
- [ ] Policy assignments applied
- [ ] No hardcoded credentials
- [ ] Terraform state locked and encrypted

### Automated Checks (Checkov)

```bash
# Run these checks before merge
checkov -d . --framework terraform \
  --check CKV_AZURE_1,CKV_AZURE_2,CKV_AZURE_3,CKV_AZURE_4,CKV_AZURE_5 \
  --check CKV_AZURE_6,CKV_AZURE_7,CKV_AZURE_8,CKV_AZURE_9,CKV_AZURE_10 \
  --check CKV_AZURE_11,CKV_AZURE_12,CKV_AZURE_13,CKV_AZURE_14 \
  --check CKV_AZURE_71,CKV_AZURE_72,CKV_AZURE_73 \
  --check CKV_AZURE_130,CKV_AZURE_131,CKV_AZURE_132 \
  --compact --framework terraform

# Output compliance report
checkov -d . --framework terraform --output cli --report-formats json > compliance-report.json
```

---

## References

- [NERC CIP Standards](https://www.nerc.net/pa/standards/Pages/default.aspx)
- [Azure Security Baseline](https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/overview)
- [Azure Architecture Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/security/security-principles)
- [CIP-002-016 Standards](https://www.nerc.net/files/standards/nerc-standards-map.pdf)

---

## Document Version

- Version: 1.0.0
- Last Updated: 2026-06-16
- Applicable Standards: NERC CIP-002, CIP-003, CIP-004, CIP-005, CIP-006, CIP-007, CIP-008, CIP-009, CIP-010, CIP-011, CIP-012, CIP-013, CIP-014
