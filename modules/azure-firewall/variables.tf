variable "name" { description = "Azure Firewall name." type = string }
variable "public_ip_name" { description = "Firewall public IP name." type = string }
variable "firewall_policy_name" { description = "Firewall policy name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "firewall_subnet_id" { description = "AzureFirewallSubnet ID." type = string }
variable "sku" { description = "Firewall SKU." type = string default = "Standard" }
variable "threat_intelligence_mode" { description = "Threat intel mode." type = string default = "Alert" }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
