variable "name" { description = "VPN gateway name." type = string }
variable "public_ip_name" { description = "VPN public IP name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "gateway_subnet_id" { description = "GatewaySubnet ID." type = string }
variable "vpn_type" { description = "VPN type." type = string default = "RouteBased" }
variable "active_active" { description = "Enable active-active." type = bool default = false }
variable "enable_bgp" { description = "Enable BGP." type = bool default = false }
variable "sku" { description = "Gateway SKU." type = string default = "VpnGw1" }
variable "generation" { description = "Gateway generation." type = string default = "Generation1" }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
