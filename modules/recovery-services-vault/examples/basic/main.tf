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
  name     = "rg-prod-eus-backup"
  location = local.location
  tags     = local.tags
}

module "recovery_services_vault" {
  source = "../../"

  name                = "rsv-prod-eus-core"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  sku                 = "Standard"
  soft_delete_enabled = true
  tags                = local.tags
}
