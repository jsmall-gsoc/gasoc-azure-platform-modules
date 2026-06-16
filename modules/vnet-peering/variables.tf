variable "source_to_remote_name" { description = "Peering name." type = string }
variable "source_resource_group_name" { description = "Source RG." type = string }
variable "source_virtual_network_name" { description = "Source VNet." type = string }
variable "remote_virtual_network_id" { description = "Remote VNet ID." type = string }
variable "allow_virtual_network_access" { description = "Allow VNet access." type = bool default = true }
variable "allow_forwarded_traffic" { description = "Allow forwarded traffic." type = bool default = true }
variable "allow_gateway_transit" { description = "Allow gateway transit." type = bool default = false }
variable "use_remote_gateways" { description = "Use remote gateways." type = bool default = false }
