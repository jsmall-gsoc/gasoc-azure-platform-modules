terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Azure OpenAI Cognitive Service Account
resource "azurerm_cognitive_account" "openai" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.sku_name

  identity {
    type = "SystemAssigned"
  }

  custom_subdomain_name = var.custom_subdomain_name
  outbound_network_access_restricted = var.outbound_network_access_restricted
  public_network_access_enabled      = var.public_network_access_enabled

  dynamic "network_acls" {
    for_each = var.enable_network_rules ? [1] : []
    content {
      default_action = var.network_default_action
      ip_rules       = var.allowed_ip_rules

      dynamic "virtual_network_rules" {
        for_each = var.allowed_subnets
        content {
          subnet_id                            = virtual_network_rules.value.subnet_id
          ignore_missing_vnet_service_endpoint = virtual_network_rules.value.ignore_missing_vnet_service_endpoint
        }
      }
    }
  }

  tags = merge(
    var.tags,
    {
      "managed-by" = "terraform"
    }
  )
}

# Azure OpenAI Model Deployments
resource "azurerm_cognitive_deployment" "models" {
  for_each = { for deployment in var.model_deployments : deployment.name => deployment }

  cognitive_account_id = azurerm_cognitive_account.openai.id
  name                 = each.value.name
  model {
    format  = each.value.model_format
    name    = each.value.model_name
    version = each.value.model_version
  }

  scale {
    type     = each.value.scale_type
    capacity = each.value.scale_capacity
  }
}

# Private Endpoint (optional)
resource "azurerm_private_endpoint" "openai" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_cognitive_account.openai.id
    subresource_names              = ["account"]
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "openai" {
  count              = var.enable_diagnostics ? 1 : 0
  name               = "${var.name}-diag"
  target_resource_id = azurerm_cognitive_account.openai.id

  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "RequestResponse"
  }

  metric {
    category = "AllMetrics"
  }
}

