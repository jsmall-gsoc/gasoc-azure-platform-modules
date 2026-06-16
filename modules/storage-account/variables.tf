variable "name" { description = "Storage account name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "account_tier" { description = "Storage account tier." type = string default = "Standard" }
variable "replication_type" { description = "Replication type." type = string default = "LRS" }
variable "shared_access_key_enabled" { description = "Enable shared access keys." type = bool default = true }
variable "public_network_access_enabled" { description = "Enable public network access." type = bool default = false }
variable "versioning_enabled" { description = "Enable blob versioning." type = bool default = true }
variable "blob_delete_retention_days" { description = "Blob delete retention days." type = number default = 7 }
variable "container_delete_retention_days" { description = "Container delete retention days." type = number default = 7 }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
