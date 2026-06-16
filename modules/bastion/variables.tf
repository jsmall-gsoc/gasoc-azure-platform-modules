variable "name" { description = "Bastion name." type = string }
variable "public_ip_name" { description = "Bastion public IP name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "bastion_subnet_id" { description = "AzureBastionSubnet ID." type = string }
variable "sku" { description = "Bastion SKU." type = string default = "Basic" }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
