resource "azurerm_security_center_subscription_pricing" "plans" {
  for_each      = var.enabled_plans
  tier          = each.value.tier
  resource_type = each.key
}

resource "azurerm_security_center_contact" "this" {
  count               = var.security_contact_email == null ? 0 : 1
  email               = var.security_contact_email
  phone               = var.security_contact_phone
  alert_notifications = var.alert_notifications
  alerts_to_admins    = var.alerts_to_admins
}
