data "azurerm_policy_set_definition" "nist" {
  name = var.policy_set_definition_name
}

resource "azurerm_management_group_policy_assignment" "this" {
  name                 = var.assignment_name
  display_name         = var.display_name
  description          = var.description
  management_group_id  = var.management_group_id
  policy_definition_id = data.azurerm_policy_set_definition.nist.id
  location             = var.location
  enforce              = var.enforce
  parameters           = var.parameters
  metadata             = jsonencode({
    assignedBy  = "GASOC Azure Platform Engineering"
    managedBy   = "Terraform"
    framework   = "NIST SP 800-53 Rev. 5"
    environment = var.environment
  })

  identity {
    type = "SystemAssigned"
  }
}
