variable "name" {
  description = "The name of the Azure OpenAI Cognitive Service Account. Must be between 2-64 characters."
  type        = string
  validation {
    condition     = length(var.name) >= 2 && length(var.name) <= 64
    error_message = "Name must be between 2-64 characters."
  }
}

variable "location" {
  description = "The Azure region where the Azure OpenAI resource will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group where the Azure OpenAI resource will be created."
  type        = string
}

variable "sku_name" {
  description = "The SKU name for the Azure OpenAI resource. Valid values are S0."
  type        = string
  default     = "S0"
  validation {
    condition     = var.sku_name == "S0"
    error_message = "Only S0 SKU is currently supported for Azure OpenAI."
  }
}

variable "custom_subdomain_name" {
  description = "The custom subdomain name for the Azure OpenAI resource. If not provided, a unique name will be generated."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Azure OpenAI resource."
  type        = bool
  default     = true
}

variable "outbound_network_access_restricted" {
  description = "Whether outbound network access is restricted for the Azure OpenAI resource."
  type        = bool
  default     = false
}

variable "model_deployments" {
  description = "List of model deployments for the Azure OpenAI resource."
  type = list(object({
    name              = string
    model_format      = string
    model_name        = string
    model_version     = string
    scale_type        = string
    scale_capacity    = number
  }))
  default = []
  
  validation {
    condition = alltrue([
      for deployment in var.model_deployments : contains(["OpenAI"], deployment.model_format)
    ])
    error_message = "Model format must be 'OpenAI'."
  }

  validation {
    condition = alltrue([
      for deployment in var.model_deployments : contains(["Standard", "ProvisionedManaged"], deployment.scale_type)
    ])
    error_message = "Scale type must be either 'Standard' or 'ProvisionedManaged'."
  }
}

variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for the Azure OpenAI resource."
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "The ID of the subnet where the private endpoint will be created. Required if enable_private_endpoint is true."
  type        = string
  default     = null
}

variable "enable_diagnostics" {
  description = "Whether to enable diagnostic settings for the Azure OpenAI resource."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace where diagnostic logs will be sent. Required if enable_diagnostics is true."
  type        = string
  default     = null
}

variable "enable_network_rules" {
  description = "Whether to enable network rules for the Azure OpenAI resource."
  type        = bool
  default     = false
}

variable "network_default_action" {
  description = "The default action for network rules. Valid values are Allow or Deny."
  type        = string
  default     = "Allow"
  validation {
    condition     = contains(["Allow", "Deny"], var.network_default_action)
    error_message = "Network default action must be either 'Allow' or 'Deny'."
  }
}

variable "allowed_ip_rules" {
  description = "List of IP addresses or CIDR blocks that are allowed to access the Azure OpenAI resource."
  type        = list(string)
  default     = []
}

variable "allowed_subnets" {
  description = "List of subnets that are allowed to access the Azure OpenAI resource via private endpoint."
  type = list(object({
    name                                = string
    subnet_id                           = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
