provider "azurerm" {
  features {}
}

module "nist_sp_800_53_r5" {
  source = "../../modules/nist-sp-800-53-r5"

  management_group_id = "/providers/Microsoft.Management/managementGroups/mg-gsoc-root"
  enforce             = false
  environment         = "enterprise"
}
