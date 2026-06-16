provider "azurerm" {
  features {}
}

module "management_groups" {
  source = "../../"

  management_groups = {
    platform = {
      name                       = "mg-gsoc-platform"
      display_name               = "GSOC Platform"
      parent_management_group_id = "/providers/Microsoft.Management/managementGroups/mg-gsoc-root"
      subscription_ids           = []
    }

    workloads = {
      name                       = "mg-gsoc-workloads"
      display_name               = "GSOC Workloads"
      parent_management_group_id = "/providers/Microsoft.Management/managementGroups/mg-gsoc-root"
      subscription_ids           = []
    }

    sandbox = {
      name                       = "mg-gsoc-sandbox"
      display_name               = "GSOC Sandbox"
      parent_management_group_id = "/providers/Microsoft.Management/managementGroups/mg-gsoc-root"
      subscription_ids           = []
    }
  }
}
