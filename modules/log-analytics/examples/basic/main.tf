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

module "log_analytics" {
  source = "../../"

  name                = "law-prod-core"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  retention_in_days   = 90
  tags                = local.tags
}
