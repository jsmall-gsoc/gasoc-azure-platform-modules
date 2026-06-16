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
  name     = "rg-prod-eus-network"
  location = local.location
  tags     = local.tags
}

module "virtual_network" {
  source = "../../"

  name                = "vnet-prod-eus-hub"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  address_space       = ["10.10.0.0/16"]
  dns_servers         = []
  tags                = local.tags
}
