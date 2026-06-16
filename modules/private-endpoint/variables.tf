variable "name" { description = "Private endpoint name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "subnet_id" { description = "Subnet ID." type = string }
variable "private_service_connection_name" { description = "Private service connection name." type = string }
variable "private_connection_resource_id" { description = "Target resource ID." type = string }
variable "subresource_names" { description = "Subresource names." type = list(string) }
variable "is_manual_connection" { description = "Manual connection." type = bool default = false }
variable "private_dns_zone_ids" { description = "Private DNS zone IDs." type = list(string) default = [] }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
