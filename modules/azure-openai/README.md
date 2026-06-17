# Azure OpenAI Terraform Module

This module provisions an Azure OpenAI cognitive account with optional model deployments, diagnostics, private endpoint support, and network access controls.

## Features

- Creates an Azure OpenAI cognitive account
- Supports one or more Azure OpenAI model deployments
- Optionally enables private endpoint connectivity
- Optionally enables diagnostic settings to Log Analytics
- Supports network ACLs with allowed IPs and allowed subnets
- Applies consistent enterprise tags

## Example

A complete working example is available at [examples/basic/main.tf](./examples/basic/main.tf).

```hcl
module "azure_openai" {
  source = "../../"

  name                               = "aoai-prod-eus-platform01"
  location                           = "eastus"
  resource_group_name                = module.rg_ai.name
  sku_name                           = "S0"
  custom_subdomain_name              = "aoai-prod-eus-platform01"
  public_network_access_enabled      = true
  outbound_network_access_restricted = false
  enable_diagnostics                 = false

  model_deployments = [
    {
      name           = "gpt-4o-mini"
      model_format   = "OpenAI"
      model_name     = "gpt-4o-mini"
      model_version  = "2024-07-18"
      scale_type     = "Standard"
      scale_capacity = 1
    }
  ]

  tags = local.tags
}
```

## Inputs

### Required

| Name | Description | Type |
|------|-------------|------|
| `name` | Name of the Azure OpenAI cognitive account | `string` |
| `location` | Azure region for deployment | `string` |
| `resource_group_name` | Target resource group name | `string` |

### Optional

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `sku_name` | Azure OpenAI SKU | `string` | `"S0"` |
| `custom_subdomain_name` | Custom subdomain for the account | `string` | `null` |
| `public_network_access_enabled` | Enable public network access | `bool` | `true` |
| `outbound_network_access_restricted` | Restrict outbound network access | `bool` | `false` |
| `model_deployments` | Model deployment definitions | `list(object)` | `[]` |
| `enable_private_endpoint` | Create a private endpoint | `bool` | `false` |
| `private_endpoint_subnet_id` | Subnet ID for the private endpoint | `string` | `null` |
| `enable_diagnostics` | Enable diagnostic settings | `bool` | `false` |
| `log_analytics_workspace_id` | Log Analytics workspace ID for diagnostics | `string` | `null` |
| `enable_network_rules` | Enable network ACLs | `bool` | `false` |
| `network_default_action` | Network default action | `string` | `"Allow"` |
| `allowed_ip_rules` | Allowed source IPs/CIDRs | `list(string)` | `[]` |
| `allowed_subnets` | Allowed subnet rules | `list(object)` | `[]` |
| `tags` | Tags applied to resources | `map(string)` | `{}` |

## Model Deployment Shape

Each item in `model_deployments` must include:

- `name`
- `model_format`
- `model_name`
- `model_version`
- `scale_type`
- `scale_capacity`

## Notes

- `sku_name` is currently constrained to `S0`.
- If `enable_private_endpoint` is `true`, `private_endpoint_subnet_id` must be supplied.
- If `enable_diagnostics` is `true`, `log_analytics_workspace_id` must be supplied.
- Network restrictions are configured through the cognitive account `network_acls` block.
