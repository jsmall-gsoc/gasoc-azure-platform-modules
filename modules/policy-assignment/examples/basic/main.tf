provider "azurerm" {
  features {}
}

data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

module "policy_assignment" {
  source = "../../"

  name                 = "asg-allowed-locations"
  display_name         = "Allowed Azure Regions"
  description          = "Restricts resource deployment to approved Azure regions."
  scope_type           = "management_group"
  scope_id             = "/providers/Microsoft.Management/managementGroups/mg-gsoc-root"
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  location             = "eastus"
  enforce              = false

  parameters = jsonencode({
    listOfAllowedLocations = {
      value = ["eastus", "eastus2"]
    }
  })

  metadata = jsonencode({
    assignedBy = "Cloud Platform Engineering"
    managedBy  = "Terraform"
  })
}
