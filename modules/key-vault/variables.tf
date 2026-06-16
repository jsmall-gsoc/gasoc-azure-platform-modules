variable "name" { description = "Key Vault name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "sku_name" { description = "SKU name." type = string default = "standard" }
variable "purge_protection_enabled" { description = "Enable purge protection." type = bool default = true }
variable "soft_delete_retention_days" { description = "Soft delete retention." type = number default = 90 }
variable "public_network_access_enabled" { description = "Enable public network access." type = bool default = false }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
