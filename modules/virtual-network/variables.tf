variable "name" { description = "VNet name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "address_space" { description = "Address space." type = list(string) }
variable "dns_servers" { description = "Custom DNS servers." type = list(string) default = [] }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
