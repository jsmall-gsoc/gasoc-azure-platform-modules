variable "name" { description = "Vault name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "sku" { description = "Vault SKU." type = string default = "Standard" }
variable "soft_delete_enabled" { description = "Enable soft delete." type = bool default = true }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
