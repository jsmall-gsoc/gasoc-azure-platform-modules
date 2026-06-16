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

module "monitor_action_group" {
  source = "../../"

  name                = "ag-prod-eus-cloudops"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "cloudops"

  email_receivers = [
    {
      name          = "CloudOps"
      email_address = "cloudops@example.com"
    }
  ]

  tags = local.tags
}
