provider "azurerm" {
  features {}
}

module "defender_for_cloud" {
  source = "../../"

  enabled_plans = {
    VirtualMachines  = { tier = "Standard" }
    StorageAccounts  = { tier = "Standard" }
    KeyVaults        = { tier = "Standard" }
    SqlServers       = { tier = "Standard" }
    AppServices      = { tier = "Standard" }
  }

  security_contact_email = "security@example.com"
  security_contact_phone = null
  alert_notifications    = true
  alerts_to_admins       = true
}
