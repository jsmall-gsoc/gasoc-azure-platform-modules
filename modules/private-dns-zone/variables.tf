variable "name" { description = "Private DNS zone name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }

variable "virtual_network_links" {
  description = "VNet links."
  type = map(object({
    virtual_network_id   = string
    registration_enabled = bool
  }))
  default = {}
}

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
