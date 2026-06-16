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

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-prod-eus-hub"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  address_space       = ["10.10.0.0/16"]
  tags                = local.tags
}

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-prod-eus-app01"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  address_space       = ["10.20.0.0/16"]
  tags                = local.tags
}

module "hub_to_spoke_peering" {
  source = "../../"

  source_to_remote_name       = "peer-hub-to-app01"
  source_resource_group_name  = azurerm_resource_group.example.name
  source_virtual_network_name = azurerm_virtual_network.hub.name
  remote_virtual_network_id   = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic     = true
  allow_gateway_transit       = true
  use_remote_gateways         = false
}

module "spoke_to_hub_peering" {
  source = "../../"

  source_to_remote_name       = "peer-app01-to-hub"
  source_resource_group_name  = azurerm_resource_group.example.name
  source_virtual_network_name = azurerm_virtual_network.spoke.name
  remote_virtual_network_id   = azurerm_virtual_network.hub.id
  allow_forwarded_traffic     = true
  allow_gateway_transit       = false
  use_remote_gateways         = false
}
