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

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-prod-core"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = local.tags
}

resource "azurerm_storage_account" "example" {
  name                            = "stproddiag001"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = local.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = local.tags
}

module "diagnostic_settings" {
  source = "../../"

  name                       = "diag-to-law"
  target_resource_id         = azurerm_storage_account.example.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  enabled_logs               = ["StorageRead", "StorageWrite", "StorageDelete"]
  metrics                    = ["Transaction"]
}
