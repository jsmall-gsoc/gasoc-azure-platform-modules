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
  name     = "rg-prod-eus-dns"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-prod-eus-hub"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  address_space       = ["10.10.0.0/16"]
  tags                = local.tags
}

module "private_dns_zone" {
  source = "../../"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name

  virtual_network_links = {
    "lnk-hub-vnet" = {
      virtual_network_id   = azurerm_virtual_network.example.id
      registration_enabled = false
    }
  }

  tags = local.tags
}
