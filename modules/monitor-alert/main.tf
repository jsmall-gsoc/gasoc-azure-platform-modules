resource "azurerm_monitor_metric_alert" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  scopes              = var.scopes
  description         = var.description
  severity            = var.severity
  frequency           = var.frequency
  window_size         = var.window_size
  enabled             = var.enabled
  tags                = var.tags

  criteria {
    metric_namespace = var.metric_namespace
    metric_name      = var.metric_name
    aggregation      = var.aggregation
    operator         = var.operator
    threshold        = var.threshold
  }

  dynamic "action" {
    for_each = var.action_group_id == null ? [] : [var.action_group_id]
    content {
      action_group_id = action.value
    }
  }
}
