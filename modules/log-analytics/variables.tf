variable "name" { description = "Workspace name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "sku" { description = "Workspace SKU." type = string default = "PerGB2018" }
variable "retention_in_days" { description = "Retention in days." type = number default = 90 }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
