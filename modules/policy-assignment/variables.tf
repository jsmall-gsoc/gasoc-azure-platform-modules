variable "name" { description = "Assignment name." type = string }
variable "display_name" { description = "Display name." type = string }
variable "description" { description = "Description." type = string default = null }
variable "scope_type" { description = "management_group or subscription." type = string }
variable "scope_id" { description = "Scope ID." type = string }
variable "policy_definition_id" { description = "Policy or policy set definition ID." type = string }
variable "location" { description = "Assignment location." type = string default = "eastus" }
variable "enforce" { description = "Enforce policy." type = bool default = false }
variable "parameters" { description = "Policy parameters JSON." type = string default = null }
variable "metadata" { description = "Metadata JSON." type = string default = null }
variable "enable_system_assigned_identity" { description = "Enable managed identity." type = bool default = true }
