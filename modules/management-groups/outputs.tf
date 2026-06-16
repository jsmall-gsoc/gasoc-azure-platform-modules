output "ids" {
  description = "Management group IDs."
  value       = { for k, v in azurerm_management_group.this : k => v.id }
}

output "names" {
  description = "Management group names."
  value       = { for k, v in azurerm_management_group.this : k => v.name }
}
