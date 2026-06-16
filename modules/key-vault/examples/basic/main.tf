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
  name     = "rg-prod-eus-security"
  location = local.location
  tags     = local.tags
}

module "key_vault" {
  source = "../../"

  name                          = "kv-prod-platform-01"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = local.location
  sku_name                      = "standard"
  purge_protection_enabled      = true
  soft_delete_retention_days    = 90
  public_network_access_enabled = false
  tags                          = local.tags
}
