variable "name" { description = "NSG name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "location" { description = "Azure region." type = string }
variable "subnet_id" { description = "Optional subnet association." type = string default = null }

variable "security_rules" {
  description = "Security rules."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
