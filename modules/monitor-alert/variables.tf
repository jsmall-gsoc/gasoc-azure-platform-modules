variable "name" { description = "Alert name." type = string }
variable "resource_group_name" { description = "Resource group name." type = string }
variable "scopes" { description = "Alert scopes." type = list(string) }
variable "description" { description = "Alert description." type = string default = null }
variable "severity" { description = "Severity." type = number default = 3 }
variable "frequency" { description = "Evaluation frequency." type = string default = "PT5M" }
variable "window_size" { description = "Window size." type = string default = "PT15M" }
variable "enabled" { description = "Enable alert." type = bool default = true }
variable "metric_namespace" { description = "Metric namespace." type = string }
variable "metric_name" { description = "Metric name." type = string }
variable "aggregation" { description = "Aggregation." type = string default = "Average" }
variable "operator" { description = "Operator." type = string default = "GreaterThan" }
variable "threshold" { description = "Threshold." type = number }
variable "action_group_id" { description = "Optional action group ID." type = string default = null }

variable "tags" {
  description = "Standard resource tags."
  type        = map(string)
  default     = {}
}
