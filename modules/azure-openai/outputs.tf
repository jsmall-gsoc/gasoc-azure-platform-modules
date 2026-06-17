output "id" {
  description = "Azure OpenAI account resource ID."
  value       = azurerm_cognitive_account.openai.id
}

output "name" {
  description = "Azure OpenAI account name."
  value       = azurerm_cognitive_account.openai.name
}

output "endpoint" {
  description = "Azure OpenAI endpoint."
  value       = azurerm_cognitive_account.openai.endpoint
}

output "principal_id" {
  description = "System-assigned managed identity principal ID."
  value       = try(azurerm_cognitive_account.openai.identity[0].principal_id, null)
}

output "model_deployment_ids" {
  description = "Map of model deployment resource IDs by deployment name."
  value       = { for name, deployment in azurerm_cognitive_deployment.models : name => deployment.id }
}

output "private_endpoint_id" {
  description = "Private endpoint resource ID when enabled."
  value       = try(azurerm_private_endpoint.openai[0].id, null)
}
