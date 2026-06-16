provider "azurerm" {
  features {}
}

locals {
  location = "eastus"

  tags = {
    Environment        = "Prod"
    Application        = "Connectivity"
    Owner              = "CloudEngineering"
    CostCenter         = "GSOC-IT"
    ManagedBy          = "Terraform"
    BusinessUnit       = "EnterpriseIT"
    DataClassification = "Internal"
    Criticality        = "High"
    BackupRequired     = "Yes"
    DisasterRecovery   = "Yes"
  }
}

module "rg_network" {
  source   = "../../modules/resource-group"
  name     = "rg-prod-eus-network"
  location = local.location
  tags     = local.tags
}

module "hub_vnet" {
  source              = "../../modules/virtual-network"
  name                = "vnet-prod-eus-hub"
  resource_group_name = module.rg_network.name
  location            = local.location
  address_space       = ["10.10.0.0/16"]
  tags                = local.tags
}

module "firewall_subnet" {
  source               = "../../modules/subnet"
  name                 = "AzureFirewallSubnet"
  resource_group_name  = module.rg_network.name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = ["10.10.0.0/26"]
}

module "bastion_subnet" {
  source               = "../../modules/subnet"
  name                 = "AzureBastionSubnet"
  resource_group_name  = module.rg_network.name
  virtual_network_name = module.hub_vnet.name
  address_prefixes     = ["10.10.0.64/26"]
}
