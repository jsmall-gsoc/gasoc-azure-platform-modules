provider "azurerm" {
  features {}
}

locals {
  location = "eastus"

  tags = {
    Environment        = "Prod"
    Application        = "AIPlatform"
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

module "rg_ai" {
  source   = "../../modules/resource-group"
  name     = "rg-prod-eus-ai"
  location = local.location
  tags     = local.tags
}

module "azure_openai" {
  source = "../../modules/azure-openai"

  name                               = "aoai-prod-eus-platform01"
  location                           = local.location
  resource_group_name                = module.rg_ai.name
  sku_name                           = "S0"
  custom_subdomain_name              = "aoai-prod-eus-platform01"
  public_network_access_enabled      = true
  outbound_network_access_restricted = false
  enable_diagnostics                 = false

  model_deployments = [
    {
      name           = "gpt-4o-mini"
      model_format   = "OpenAI"
      model_name     = "gpt-4o-mini"
      model_version  = "2024-07-18"
      scale_type     = "Standard"
      scale_capacity = 1
    },
    {
      name           = "text-embedding-3-large"
      model_format   = "OpenAI"
      model_name     = "text-embedding-3-large"
      model_version  = "1"
      scale_type     = "Standard"
      scale_capacity = 1
    }
  ]

  tags = local.tags
}