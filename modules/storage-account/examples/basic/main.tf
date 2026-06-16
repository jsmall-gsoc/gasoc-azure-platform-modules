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
  name     = "rg-prod-eus-storage"
  location = local.location
  tags     = local.tags
}

module "storage_account" {
  source = "../../"

  name                          = "stprodexample001"
  resource_group_name           = azurerm_resource_group.example.name
  location                      = local.location
  replication_type              = "LRS"
  public_network_access_enabled = false
  shared_access_key_enabled     = true
  tags                          = local.tags
}
