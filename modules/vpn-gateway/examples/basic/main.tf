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

resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.10.255.0/27"]
}

module "vpn_gateway" {
  source = "../../"

  name                = "vpng-prod-eus-hub"
  public_ip_name      = "pip-prod-eus-vpng-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  gateway_subnet_id   = azurerm_subnet.gateway.id
  sku                 = "VpnGw1"
  generation          = "Generation1"
  enable_bgp          = false
  active_active       = false
  tags                = local.tags
}
