# Checkov Configuration - NERC CIP Security Scanning

Checkov is an infrastructure-as-code (IaC) security scanner that identifies misconfigurations and compliance violations.

## Installation

```bash
# Via pip
pip install checkov

# Via apt
sudo apt-get install checkov

# Via Docker
docker run --rm -v $(pwd):/tf bridgecrewio/checkov -d /tf --framework terraform
```

## Configuration

Copy checkov config to repo root:

```bash
cp .checkov.yaml ../../..
```

## Running Checkov

```bash
# Scan all Terraform files
checkov -d . --framework terraform --compact

# Check specific check categories (NERC CIP)
checkov -d . --framework terraform \
  --check CKV_AZURE_1,CKV_AZURE_2,CKV_AZURE_3,CKV_AZURE_4,CKV_AZURE_5,CKV_AZURE_6,CKV_AZURE_7,CKV_AZURE_8,CKV_AZURE_9,CKV_AZURE_10 \
  --check CKV_AZURE_11,CKV_AZURE_12,CKV_AZURE_13,CKV_AZURE_14 \
  --check CKV_AZURE_71,CKV_AZURE_72,CKV_AZURE_73,CKV_AZURE_74,CKV_AZURE_75

# Output JSON report
checkov -d . --framework terraform --output json > checkov-report.json

# Output SARIF (GitHub/GitLab compatible)
checkov -d . --framework terraform --output sarif > checkov-report.sarif

# Output cyclonedx (SBOM)
checkov -d . --framework terraform --output cyclonedx > sbom.json

# Check with severity filter
checkov -d . --framework terraform --compact --check-runner framework --severity HIGH CRITICAL
```

## NERC CIP Compliance Checks

### CIP-002/003: Classification & Security Management
- `CKV_AZURE_1`: Ensure that Virtual Machines use managed disks
- `CKV_AZURE_2`: Ensure that VM agent is installed
- `CKV_AZURE_3`: Ensure that virtual machines are created with Approved base images only
- `CKV_AZURE_71`: Ensure that logging for Azure Key Vault is 'Enabled'
- `CKV_AZURE_72`: Ensure that Activity Log Alert exists for Create Policy Assignment
- `CKV_AZURE_73`: Ensure that Activity Log Alert exists for Delete Policy Assignment
- `CKV_AZURE_74`: Ensure that Activity Log Alert exists for Create or Update Network Security Group
- `CKV_AZURE_75`: Ensure that Activity Log Alert exists for Delete Network Security Group

### CIP-004/005: Personnel Access & System Security
- `CKV_AZURE_4`: Ensure that 'Managed identity' is used for Azure resources
- `CKV_AZURE_5`: Ensure RBAC is used for all Azure resources
- `CKV_AZURE_6`: Ensure that Network Security Groups rules do not allow ingress from 0.0.0.0:0 to port 3389
- `CKV_AZURE_7`: Ensure that Network Security Groups rules do not allow ingress from 0.0.0.0:0 to port 22
- `CKV_AZURE_8`: Ensure that Network Security Groups rules do not allow ingress from 0.0.0.0:0 to port 443

### CIP-006/014: Physical & Network Security
- `CKV_AZURE_9`: Ensure DDoS Protection Standard is enabled
- `CKV_AZURE_10`: Ensure that Firewall is enabled for all databases
- `CKV_AZURE_11`: Ensure that Virtual Machines use a managed disk
- `CKV_AZURE_12`: Ensure that storage blobs restrict public access

### CIP-007: System Security Management
- `CKV_AZURE_13`: Ensure that storage accounts use a virtual service endpoint
- `CKV_AZURE_14`: Ensure that Application Gateway has WAF enabled
- `CKV_AZURE_77`: Ensure that 'Automatic updates' is set to 'On' for Windows machines

### CIP-008: Incident Response
- `CKV_AZURE_38`: Ensure that 'All' blob service logging is 'Enabled' for read, write, and delete requests
- `CKV_AZURE_39`: Ensure that 'All' logging for Azure Queue Storage is 'Enabled'
- `CKV_AZURE_40`: Ensure that 'All' logging for Azure Table Storage is 'Enabled'

### CIP-009: Recovery Plans
- `CKV_AZURE_41`: Ensure that virtual machines are backed up via Azure Backup
- `CKV_AZURE_42`: Ensure that backup policy is defined for virtual machines
- `CKV_AZURE_43`: Ensure that backup policy retention is at least 30 days

### CIP-010: Configuration Management
- `CKV_AZURE_50`: Ensure that Azure Policy is used to restrict resource creation
- `CKV_AZURE_51`: Ensure that Azure Policy restricts enforcement mode
- `CKV_AZURE_52`: Ensure that Azure Key Vault enables purge protection
- `CKV_AZURE_53`: Ensure that Azure Key Vault enables soft delete

### CIP-011: Information Protection
- `CKV_AZURE_15`: Ensure that storage accounts use customer-managed keys for encryption
- `CKV_AZURE_16`: Ensure that storage accounts have 'Secure transfer required' enabled
- `CKV_AZURE_17`: Ensure that Azure SQL Server uses a minimum of TLS 1.2
- `CKV_AZURE_18`: Ensure that 'Transparent Data Encryption' is 'On' when using Azure SQL Database

### CIP-012: Supply Chain Risk Management
- Checkov automatically scans for vulnerable dependencies in Terraform modules

### CIP-013: Transient Devices
- `CKV_AZURE_1`: Ensure that Virtual Machines use managed disks (no unmanaged)
- `CKV_AZURE_2`: Ensure disk encryption is enabled

---

## Configuration File (.checkov.yaml)

```yaml
# Location of this file: repository root (.checkov.yaml)

framework:
  - terraform

# Soft-fail on these checks (log but don't fail)
soft-fail:
  - CKV_AZURE_100  # Example: non-critical check

# Hard-fail on these checks (fail build)
hard-fail:
  - CKV_AZURE_1    # Managed disks required
  - CKV_AZURE_4    # Managed identity required
  - CKV_AZURE_52   # Key Vault purge protection required
  - CKV_AZURE_53   # Key Vault soft delete required

# Severity levels to check
check:
  - "HIGH"
  - "CRITICAL"
  - "MEDIUM"  # Include medium for NERC compliance

# Skip specific directories
skip-download:
  - false  # Download latest check definitions

# External checks
external-checks-dir:
  - ./checks/custom  # Optional custom checks

# Output format
output:
  format: "cli,json,sarif"
  files:
    - checkov-report.json
    - checkov-report.sarif

# Exclude paths
exclude-paths:
  - ".terraform"
  - ".git"
  - "test"
  - "docs"

# Exclude checks
exclude-checks:
  # None for NERC compliance (all checks must pass)

# Include checks
include-checks:
  - CKV_AZURE_*  # All Azure checks

# Logging
log-level: "INFO"  # DEBUG for troubleshooting

# Persistence
quiet: false
compact: false

# Definition location
definitions:
  - https://raw.githubusercontent.com/bridgecrewio/checkov/master/checkov/terraform/checks
```

---

## CI/CD Integration

### Azure DevOps Pipeline

```yaml
# .azure-pipelines/checkov.yml
trigger:
  - main
  - develop

pool:
  vmImage: ubuntu-latest

steps:
  - task: UsePythonVersion@0
    inputs:
      versionSpec: '3.11'
    displayName: Use Python 3.11

  - script: |
      pip install checkov
    displayName: Install Checkov

  - script: |
      checkov -d . --framework terraform \
        --output cli \
        --output json --output-file-path checkov-report.json \
        --compact \
        --severity HIGH CRITICAL
    displayName: Run Checkov Security Scan
    continueOnError: false

  - task: PublishBuildArtifacts@1
    inputs:
      PathtoPublish: checkov-report.json
      ArtifactName: checkov-reports
    condition: always()

  - script: |
      # Fail if critical issues found
      CRITICAL_ISSUES=$(jq '.summary.failed // 0' checkov-report.json)
      if [ $CRITICAL_ISSUES -gt 0 ]; then
        echo "##vso[task.logissue type=error]Checkov found $CRITICAL_ISSUES CRITICAL issues"
        exit 1
      fi
    displayName: Fail on Critical Issues
```

### GitHub Actions

```yaml
# .github/workflows/checkov.yml
name: Checkov Security Scan

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  checkov:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@master
        with:
          directory: .
          framework: terraform
          output_format: sarif
          output_file_path: checkov-report.sarif
          
      - name: Upload SARIF Report
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: checkov-report.sarif
```

---

## Interpreting Results

### Report Structure

```json
{
  "summary": {
    "failed": 5,
    "passed": 45,
    "skipped": 2,
    "parsing_errors": 0
  },
  "results": {
    "failed_checks": [
      {
        "check_id": "CKV_AZURE_52",
        "check_name": "Ensure that Azure Key Vault enables purge protection",
        "check_result": {
          "result": "FAILED"
        },
        "resource": "azurerm_key_vault.legacy",
        "file_path": "./modules/key-vault/main.tf",
        "file_line_range": [1, 15],
        "code_block": [
          [1, "resource \"azurerm_key_vault\" \"legacy\" {"]
        ],
        "guideline": "https://learn.microsoft.com/en-us/azure/key-vault/general/key-vault-recovery-overview"
      }
    ]
  }
}
```

### Fixing Issues

Priority order:
1. **CRITICAL**: Fix immediately (blocking deployment)
2. **HIGH**: Fix before merge
3. **MEDIUM**: Fix in current sprint
4. **LOW**: Fix in backlog

Example fix for missing purge protection:

```hcl
# ❌ BEFORE (CKV_AZURE_52 failure)
resource "azurerm_key_vault" "this" {
  name = "mykeyvault"
}

# ✅ AFTER
resource "azurerm_key_vault" "this" {
  name                       = "mykeyvault"
  purge_protection_enabled   = true  # Added
  soft_delete_retention_days = 90    # Added
}
```

---

## Custom NERC CIP Checks

Create custom checks in `./checks/custom/`:

```python
# checks/custom/cip_005_network_security.py
from checkov.common.checks.base_check import BaseResourceCheck
from checkov.common.checks.base_resource_negative_value_check import BaseResourceNegativeValueCheck
from checkov.terraform.checks.resource.registry import Registry

registry = Registry()

@registry.register_check(resource_types=['azurerm_network_security_group_rule'], 
                        id='CKV_CUSTOM_NERC_005_001')
class NSGNoPublicInternetIngress(BaseResourceNegativeValueCheck):
    """
    NERC CIP-005: Ensure NSG rules don't allow public internet ingress
    """
    def __init__(self):
        name = "Ensure NSG rules don't allow 0.0.0.0/0 to any port"
        id = "CKV_CUSTOM_NERC_005_001"
        supported_resources = ['azurerm_network_security_group_rule']
        categories = ['NETWORKING']
        super().__init__(name=name, id=id, categories=categories, supported_resources=supported_resources)

    def get_inspected_key(self) -> str:
        return "source_address_prefix"

    def get_forbidden_values(self):
        return ["0.0.0.0/0", "*", "internet", "<nw>/0"]
```

Register custom checks:

```bash
checkov -d . --framework terraform --external-checks-dir ./checks/custom
```

---

## Troubleshooting

### Checkov Not Finding Issues

```bash
# Check definition version
checkov --version

# Update definitions
checkov --download-latest-pb2

# Run with debug output
checkov -d . --framework terraform --log-level DEBUG
```

### False Positives

Suppress with inline comments:

```hcl
# checkov:skip=CKV_AZURE_100:This is accepted risk (CIP exemption #456)
resource "azurerm_storage_account" "legacy" {
  # ...
}
```

Document the exemption in a tracking issue.

---

## Resources

- [Checkov Documentation](https://www.checkov.io/docs)
- [CKV Azure Checks](https://www.checkov.io/docs/terraform/checks/resource/azure)
- [NERC CIP Mapping](./NERC_CIP_COMPLIANCE.md)
- [Azure Security Benchmark](https://learn.microsoft.com/en-us/security/benchmark/azure/)
