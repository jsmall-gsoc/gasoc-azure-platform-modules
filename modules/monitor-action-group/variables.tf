variable "name" { description = "Action group name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "short_name" { description = "Short name." type = string }

variable "email_receivers" {
  description = "Email receivers."
  type = list(object({
    name          = string
    email_address = string
  }))
  default = []
}

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
