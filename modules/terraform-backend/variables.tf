variable "resource_group_name" { description = "Terraform backend resource group." type = string }
variable "storage_account_name" { description = "Terraform state storage account." type = string }
variable "container_name" { description = "State container name." type = string default = "tfstate" }
variable "location" { description = "Azure region." type = string default = "eastus" }
variable "replication_type" { description = "Storage replication type." type = string default = "LRS" }
variable "public_network_access_enabled" { description = "Enable public network access." type = bool default = false }
variable "shared_access_key_enabled" { description = "Enable shared access key." type = bool default = true }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
