provider "azurerm" {
  features {}
}

locals {
  location = "eastus"

  tags = {
    Environment        = "Prod"
    Application        = "PlatformCore"
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

module "rg_management" {
  source   = "../../modules/resource-group"
  name     = "rg-prod-eus-management"
  location = local.location
  tags     = local.tags
}

module "log_analytics" {
  source              = "../../modules/log-analytics"
  name                = "law-prod-core"
  resource_group_name = module.rg_management.name
  location            = local.location
  retention_in_days   = 90
  tags                = local.tags
}

module "key_vault" {
  source                        = "../../modules/key-vault"
  name                          = "kv-prod-platform-01"
  resource_group_name           = module.rg_management.name
  location                      = local.location
  public_network_access_enabled = false
  tags                          = local.tags
}
