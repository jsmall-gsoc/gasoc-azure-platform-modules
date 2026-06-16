variable "policy_set_definition_name" {
  description = "Built-in NIST SP 800-53 Rev. 5 initiative definition name/id."
  type        = string
  default     = "179d1daa-458f-4e47-8086-2a68d0d6c38f"
}

variable "assignment_name" { description = "Assignment name." type = string default = "asg-nist-800-53-r5" }
variable "display_name" { description = "Display name." type = string default = "NIST SP 800-53 Rev. 5 Baseline" }
variable "description" { description = "Description." type = string default = "Assigns the Microsoft built-in NIST SP 800-53 Rev. 5 regulatory compliance initiative." }
variable "management_group_id" { description = "Management group scope ID." type = string }
variable "location" { description = "Assignment location." type = string default = "eastus" }
variable "enforce" { description = "Whether to enforce policy." type = bool default = false }
variable "parameters" { description = "Policy parameters JSON." type = string default = null }
variable "environment" { description = "Environment label." type = string default = "enterprise" }
