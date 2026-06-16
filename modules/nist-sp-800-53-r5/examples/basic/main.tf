provider "azurerm" {
  features {}
}

module "nist_sp_800_53_r5" {
  source = "../../"

  management_group_id = "/providers/Microsoft.Management/managementGroups/mg-gsoc-root"
  enforce             = false
  environment         = "enterprise"
}
