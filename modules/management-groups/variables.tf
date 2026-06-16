variable "management_groups" {
  description = "Management groups to create."
  type = map(object({
    name                       = string
    display_name               = string
    parent_management_group_id = optional(string)
    subscription_ids           = optional(list(string), [])
  }))
}
