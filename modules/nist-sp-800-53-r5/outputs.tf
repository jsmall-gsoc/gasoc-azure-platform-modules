output "assignment_id" {
	description = "Assignment ID."
	value       = azurerm_management_group_policy_assignment.this.id
}

output "principal_id" {
	description = "Managed identity principal ID."
	value       = azurerm_management_group_policy_assignment.this.identity[0].principal_id
}

output "policy_set_definition_id" {
	description = "Policy set definition ID."
	value       = data.azurerm_policy_set_definition.nist.id
}
