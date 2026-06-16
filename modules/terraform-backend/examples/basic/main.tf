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


module "terraform_backend" {
  source = "../../"

  resource_group_name           = "rg-prod-eus-tfstate"
  storage_account_name          = "stprodtfstate001"
  container_name                = "tfstate"
  location                      = local.location
  replication_type              = "LRS"
  public_network_access_enabled = false
  shared_access_key_enabled     = true
  tags                          = local.tags
}
