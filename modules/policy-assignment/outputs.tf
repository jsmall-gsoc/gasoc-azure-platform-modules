output "id" {
  description = "Policy assignment ID."
  value       = var.scope_type == "management_group" ? azurerm_management_group_policy_assignment.this[0].id : azurerm_subscription_policy_assignment.this[0].id
}

output "principal_id" {
  description = "Managed identity principal ID."
  value = var.enable_system_assigned_identity ? (
    var.scope_type == "management_group" ? azurerm_management_group_policy_assignment.this[0].identity[0].principal_id : azurerm_subscription_policy_assignment.this[0].identity[0].principal_id
  ) : null
}
