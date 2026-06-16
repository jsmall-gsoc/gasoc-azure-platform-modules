variable "name" { description = "Diagnostic setting name." type = string default = "diag-to-law" }
variable "target_resource_id" { description = "Target resource ID." type = string }
variable "log_analytics_workspace_id" { description = "Log Analytics workspace ID." type = string }
variable "enabled_logs" { description = "Enabled log categories." type = list(string) default = [] }
variable "metrics" { description = "Enabled metric categories." type = list(string) default = ["AllMetrics"] }
