resource "azurerm_management_group" "this" {
  for_each                   = var.management_groups
  name                       = each.value.name
  display_name               = each.value.display_name
  parent_management_group_id = each.value.parent_management_group_id
  subscription_ids           = each.value.subscription_ids
}
