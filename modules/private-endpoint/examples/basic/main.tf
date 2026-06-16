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
  name     = "rg-prod-eus-private-endpoint"
  location = local.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-prod-eus-app01"
  resource_group_name = azurerm_resource_group.example.name
  location            = local.location
  address_space       = ["10.20.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "private_endpoints" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.20.10.0/24"]
}

resource "azurerm_storage_account" "example" {
  name                            = "stprodpeexample01"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = local.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = local.tags
}

module "private_endpoint" {
  source = "../../"

  name                            = "pe-prod-eus-storage-blob"
  resource_group_name             = azurerm_resource_group.example.name
  location                        = local.location
  subnet_id                       = azurerm_subnet.private_endpoints.id
  private_service_connection_name = "psc-storage-blob"
  private_connection_resource_id  = azurerm_storage_account.example.id
  subresource_names               = ["blob"]
  private_dns_zone_ids            = []
  tags                            = local.tags
}
