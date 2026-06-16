variable "enabled_plans" {
  description = "Defender plans."
  type = map(object({
    tier = string
  }))
  default = {
    VirtualMachines = { tier = "Standard" }
    StorageAccounts = { tier = "Standard" }
    KeyVaults = { tier = "Standard" }
    SqlServers = { tier = "Standard" }
    AppServices = { tier = "Standard" }
  }
}

variable "security_contact_email" { description = "Security contact email." type = string default = null }
variable "security_contact_phone" { description = "Security contact phone." type = string default = null }
variable "alert_notifications" { description = "Enable alert notifications." type = bool default = true }
variable "alerts_to_admins" { description = "Send alerts to admins." type = bool default = true }
