variable "name" { description = "Route table name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "bgp_route_propagation_enabled" { description = "Enable BGP propagation." type = bool default = true }
variable "subnet_id" { description = "Optional subnet association." type = string default = null }

variable "routes" {
  description = "Routes."
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
