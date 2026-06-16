variable "name" { description = "Subnet name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "virtual_network_name" { description = "Virtual network name." type = string }
variable "address_prefixes" { description = "Subnet CIDR prefixes." type = list(string) }
variable "service_endpoints" { description = "Service endpoints." type = list(string) default = [] }

variable "delegations" {
  description = "Subnet delegations."
  type = list(object({
    name         = string
    service_name = string
    actions      = list(string)
  }))
  default = []
}
