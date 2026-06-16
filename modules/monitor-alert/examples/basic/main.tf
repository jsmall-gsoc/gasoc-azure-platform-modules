provider "azurerm" {
  features {}
}


locals {
  location = "eastus"

  tags = {
    Environment        = "Prod"
    Application        = "Example"
    Owner              = "CloudEngineering"
    CostCenter         = "GSOC-IT"
    ManagedBy          = "Terraform"
    BusinessUnit       = "EnterpriseIT"
    DataClassification = "Internal"
    Criticality        = "Medium"
    BackupRequired     = "No"
    DisasterRecovery   = "No"
  }
}


resource "azurerm_resource_group" "example" {
  name     = "rg-prod-eus-monitoring"
  location = local.location
  tags     = local.tags
}

resource "azurerm_storage_account" "example" {
  name                            = "stprodalert001"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = local.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = local.tags
}

module "monitor_alert" {
  source = "../../"

  name                 = "ma-prod-eus-storage-availability"
  resource_group_name  = azurerm_resource_group.example.name
  scopes               = [azurerm_storage_account.example.id]
  description          = "Alert when storage availability drops below threshold."
  metric_namespace     = "Microsoft.Storage/storageAccounts"
  metric_name          = "Availability"
  aggregation          = "Average"
  operator             = "LessThan"
  threshold            = 99
  action_group_id      = null
  tags                 = local.tags
}
