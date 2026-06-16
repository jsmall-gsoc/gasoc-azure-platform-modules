output "enabled_plans" { description = "Enabled Defender plans." value = keys(azurerm_security_center_subscription_pricing.plans) }
