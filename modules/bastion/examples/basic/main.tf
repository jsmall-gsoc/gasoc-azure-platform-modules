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

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.10.0.64/26"]
}

module "bastion" {
  source = "../../"

  name                = "bas-prod-eus-hub"
  public_ip_name      = "pip-prod-eus-bas-01"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  bastion_subnet_id   = azurerm_subnet.bastion.id
  sku                 = "Basic"
  tags                = local.tags
}
