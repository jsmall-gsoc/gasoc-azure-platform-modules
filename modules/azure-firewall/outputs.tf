output "id" { description = "Firewall ID." value = azurerm_firewall.this.id }
output "private_ip_address" { description = "Firewall private IP." value = azurerm_firewall.this.ip_configuration[0].private_ip_address }
output "policy_id" { description = "Firewall policy ID." value = azurerm_firewall_policy.this.id }
