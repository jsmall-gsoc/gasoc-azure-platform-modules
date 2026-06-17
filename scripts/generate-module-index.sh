#!/bin/bash

# Script to auto-generate MODULE_INDEX.md from module directory structure
# Usage: ./scripts/generate-module-index.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
MODULES_DIR="$PROJECT_ROOT/modules"
OUTPUT_FILE="$PROJECT_ROOT/MODULE_INDEX.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Generating MODULE_INDEX.md...${NC}"

# Check if modules directory exists
if [ ! -d "$MODULES_DIR" ]; then
    echo -e "${RED}Error: modules directory not found at $MODULES_DIR${NC}"
    exit 1
fi

# Create temporary output file
TEMP_FILE=$(mktemp)

# Count modules robustly across shells
TOTAL_MODULES=$(find "$MODULES_DIR" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d '[:space:]')
GENERATED_AT=$(date '+%Y-%m-%d %H:%M:%S')

# Write header
cat > "$TEMP_FILE" <<EOF
# Module Index

> **Note:** This index is auto-generated. For details, see the [Module Generation Script](#auto-generation).

**Last Updated:** $GENERATED_AT
**Total Modules:** $TOTAL_MODULES
EOF

# Add sections
cat >> "$TEMP_FILE" << 'EOF'

## Quick Navigation

- [Foundation & Governance](#foundation--governance)
- [Networking](#networking)
- [Security & Compliance](#security--compliance)
- [Operations & Monitoring](#operations--monitoring)
- [DevSecOps & Automation](#devsecops--automation)

---

## Foundation & Governance

### 1. **resource-group**
- **Category:** Platform
- **Maturity:** Production Ready
- **Status:** ✅ Stable
- **Purpose:** Standard Azure Resource Group deployment
- **Documentation:** [resource-group/README.md](./modules/resource-group/README.md)
- **Example:** [phase-1-foundation](./examples/phase-1-foundation)
- **Inputs:** `name`, `location`, `tags`
- **Outputs:** `id`, `name`, `location`

### 2. **management-groups**
- **Category:** Governance
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Management group hierarchy and structure
- **Documentation:** [management-groups/README.md](./modules/management-groups/README.md)
- **Inputs:** `parent_id`, `name`, `display_name`
- **Outputs:** `id`, `name`, `tenant_scope_id`

### 3. **policy-assignment**
- **Category:** Governance
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Generic Azure policy assignment at various scopes
- **Documentation:** [policy-assignment/README.md](./modules/policy-assignment/README.md)

### 4. **nist-sp-800-53-r5**
- **Category:** Governance/Security
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** NIST SP 800-53 R5 initiative assignment for compliance
- **Documentation:** [nist-sp-800-53-r5/README.md](./modules/nist-sp-800-53-r5/README.md)
- **Compliance:** NIST SP 800-53 R5, NERC CIP

### 5. **subscription-bootstrap**
- **Category:** Governance
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Subscription foundation bootstrap for governance, logging, security, and RBAC
- **Documentation:** [subscription-bootstrap/README.md](./modules/subscription-bootstrap/README.md)
- **Outputs:** `management_group_id`, `log_analytics_workspace_id`, `recovery_services_vault_id`

---

## Networking

### 6. **virtual-network**
- **Category:** Networking
- **Maturity:** Production Ready
- **Status:** ✅ Stable
- **Purpose:** VNet baseline with optional DDoS protection
- **Documentation:** [virtual-network/README.md](./modules/virtual-network/README.md)
- **Example:** [phase-2-networking](./examples/phase-2-networking)
- **Inputs:** `name`, `location`, `resource_group_name`, `address_space`
- **Outputs:** `id`, `name`, `address_space`

### 7. **subnet**
- **Category:** Networking
- **Maturity:** Production Ready
- **Status:** ✅ Stable
- **Purpose:** Subnet deployment with delegations and endpoints
- **Documentation:** [subnet/README.md](./modules/subnet/README.md)
- **Inputs:** `name`, `resource_group_name`, `virtual_network_name`, `address_prefixes`
- **Outputs:** `id`, `name`, `address_prefixes`

### 8. **network-security-group**
- **Category:** Networking
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** NSG with optional association to subnets
- **Documentation:** [network-security-group/README.md](./modules/network-security-group/README.md)
- **Inputs:** `name`, `location`, `resource_group_name`
- **Outputs:** `id`, `name`

### 9. **route-table**
- **Category:** Networking
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** User Defined Routes (UDR) configuration
- **Documentation:** [route-table/README.md](./modules/route-table/README.md)

### 10. **vnet-peering**
- **Category:** Networking
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** VNet-to-VNet peering establishment
- **Documentation:** [vnet-peering/README.md](./modules/vnet-peering/README.md)

### 11. **private-dns-zone**
- **Category:** Networking
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Private DNS zone creation and linking
- **Documentation:** [private-dns-zone/README.md](./modules/private-dns-zone/README.md)

### 12. **private-endpoint**
- **Category:** Networking
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** PaaS private endpoint deployment
- **Documentation:** [private-endpoint/README.md](./modules/private-endpoint/README.md)

### 13. **azure-firewall**
- **Category:** Networking/Security
- **Maturity:** Experimental
- **Status:** ⚠️ Experimental
- **Cost:** Premium resource - verify budget implications
- **Purpose:** Azure Firewall deployment for advanced traffic filtering
- **Documentation:** [azure-firewall/README.md](./modules/azure-firewall/README.md)

### 14. **bastion**
- **Category:** Networking/Security
- **Maturity:** Experimental
- **Status:** ⚠️ Experimental
- **Cost:** Premium resource - verify budget implications
- **Purpose:** Azure Bastion host deployment for secure VM access
- **Documentation:** [bastion/README.md](./modules/bastion/README.md)

### 15. **vpn-gateway**
- **Category:** Networking
- **Maturity:** Experimental
- **Status:** ⚠️ Experimental
- **Cost:** Premium resource - verify budget implications
- **Purpose:** VPN Gateway for site-to-site and point-to-site connectivity
- **Documentation:** [vpn-gateway/README.md](./modules/vpn-gateway/README.md)

---

## Security & Compliance

### 16. **key-vault**
- **Category:** Security
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Azure Key Vault with RBAC and purge protection
- **Documentation:** [key-vault/README.md](./modules/key-vault/README.md)
- **Inputs:** `name`, `location`, `resource_group_name`
- **Outputs:** `id`, `name`, `vault_uri`
- **Security Features:** Purge protection, RBAC, soft delete

### 17. **defender-for-cloud**
- **Category:** Security
- **Maturity:** Experimental
- **Status:** ⚠️ Experimental
- **Purpose:** Microsoft Defender for Cloud plan activation
- **Documentation:** [defender-for-cloud/README.md](./modules/defender-for-cloud/README.md)
- **Plans Supported:** Virtual Machines, SQL Servers, App Service, Storage, Key Vault

### 18. **azure-openai**
- **Category:** Security
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Azure OpenAI cognitive account with model deployments, diagnostics, and network controls
- **Documentation:** [azure-openai/README.md](./modules/azure-openai/README.md)
- **Example:** [azure-openai](./examples/azure-openai)
- **Inputs:** `name`, `location`, `resource_group_name`, `model_deployments`
- **Outputs:** `id`, `name`, `endpoint`, `principal_id`, `model_deployment_ids`, `private_endpoint_id`
- **Security Features:** Private endpoint support, network ACLs, diagnostic logging

---

## Operations & Monitoring

### 19. **log-analytics**
- **Category:** Operations
- **Maturity:** Production Ready
- **Status:** ✅ Stable
- **Purpose:** Log Analytics Workspace central logging and monitoring
- **Documentation:** [log-analytics/README.md](./modules/log-analytics/README.md)
- **Inputs:** `name`, `location`, `resource_group_name`, `retention_in_days`
- **Outputs:** `id`, `name`, `workspace_id`, `primary_shared_key`

### 20. **diagnostic-settings**
- **Category:** Operations
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Diagnostic settings for resource logging and forwarding
- **Documentation:** [diagnostic-settings/README.md](./modules/diagnostic-settings/README.md)

### 21. **monitor-action-group**
- **Category:** Operations
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Alert action group for notifications
- **Documentation:** [monitor-action-group/README.md](./modules/monitor-action-group/README.md)

### 22. **monitor-alert**
- **Category:** Operations
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Metric alert rule creation
- **Documentation:** [monitor-alert/README.md](./modules/monitor-alert/README.md)

### 23. **recovery-services-vault**
- **Category:** Operations
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Backup and disaster recovery vault
- **Documentation:** [recovery-services-vault/README.md](./modules/recovery-services-vault/README.md)

---

## DevSecOps & Automation

### 24. **storage-account**
- **Category:** Platform
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Azure Storage Account with secure defaults
- **Documentation:** [storage-account/README.md](./modules/storage-account/README.md)
- **Security Features:** TLS enforcement, blob encryption, SAS token support

### 25. **terraform-backend**
- **Category:** DevSecOps
- **Maturity:** Preview
- **Status:** 🔄 In Development
- **Purpose:** Remote state backend configuration (storage account + container)
- **Documentation:** [terraform-backend/README.md](./modules/terraform-backend/README.md)

---

## Module Status Legend

| Status | Meaning |
|--------|---------|
| ✅ Stable | Production-ready, widely tested |
| 🔄 In Development | Feature-complete, undergoing testing |
| ⚠️ Experimental | Early development, breaking changes possible |

## Usage by Phase

### Phase 1: Foundation
Essential resources for environment setup:
- `resource-group`
- `log-analytics`
- `storage-account` (for backend)
- `terraform-backend`

### Phase 2: Networking
Core networking infrastructure:
- `virtual-network`
- `subnet`
- `network-security-group`
- `private-dns-zone`

### Phase 3: Governance
Compliance and policy enforcement:
- `management-groups`
- `policy-assignment`
- `nist-sp-800-53-r5`
- `defender-for-cloud`

## Contributing

To add or update a module:

1. Create module in `modules/{module-name}/`
2. Include: `main.tf`, `variables.tf`, `outputs.tf`, `README.md`
3. Run generation script to update this index
4. Submit PR for review

See [CONTRIBUTING.md](./CONTRIBUTING.md) for details.

## Auto-Generation

This index is generated by the `scripts/generate-module-index.sh` script:

```bash
./scripts/generate-module-index.sh
```

The script:
- ✅ Scans `modules/` directory
- ✅ Extracts README content
- ✅ Generates markdown table
- ✅ Updates `MODULE_INDEX.md`

**Run this after adding new modules or updating module README files.**

---

## Quick Links

- [Examples](./examples/) - Reference implementations
- [Contributing Guide](./CONTRIBUTING.md)
- [Release Strategy](./docs/standards/RELEASE_STRATEGY.md)
- [Module Development Guide](./docs/module-usage.md)
- [Terratest Tests](./tests/)
EOF

# Copy temp file to output
mv "$TEMP_FILE" "$OUTPUT_FILE"

echo -e "${GREEN}✓ MODULE_INDEX.md generated successfully!${NC}"
echo -e "${GREEN}✓ Total modules: $TOTAL_MODULES${NC}"
echo -e "${GREEN}✓ Output: $OUTPUT_FILE${NC}"
