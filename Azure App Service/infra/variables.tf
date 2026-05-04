variable "resource_group_name" {
  type        = string
  description = "Resource group for App Service resources"
}

variable "location" {
  type        = string
  description = "Azure region"
  default     = "Central India"
}

variable "app_service_plan_name" {
  type        = string
  description = "App Service Plan name"
}

variable "web_app_name" {
  type        = string
  description = "Unique Web App name"
}

variable "sku_name" {
  type        = string
  description = "App Service Plan SKU"
  default     = "B1"
}

