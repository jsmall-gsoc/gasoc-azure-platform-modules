resource "azurerm_management_group_policy_assignment" "this" {
  count                = var.scope_type == "management_group" ? 1 : 0
  name                 = var.name
  display_name         = var.display_name
  description          = var.description
  management_group_id  = var.scope_id
  policy_definition_id = var.policy_definition_id
  location             = var.location
  enforce              = var.enforce
  parameters           = var.parameters
  metadata             = var.metadata

  dynamic "identity" {
    for_each = var.enable_system_assigned_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}

resource "azurerm_subscription_policy_assignment" "this" {
  count                = var.scope_type == "subscription" ? 1 : 0
  name                 = var.name
  display_name         = var.display_name
  description          = var.description
  subscription_id      = var.scope_id
  policy_definition_id = var.policy_definition_id
  location             = var.location
  enforce              = var.enforce
  parameters           = var.parameters
  metadata             = var.metadata

  dynamic "identity" {
    for_each = var.enable_system_assigned_identity ? [1] : []
    content {
      type = "SystemAssigned"
    }
  }
}
