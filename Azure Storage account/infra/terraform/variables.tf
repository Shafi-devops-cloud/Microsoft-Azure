variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name. Must be globally unique and lowercase."
}

variable "account_tier" {
  type        = string
}

variable "replication_type" {
  type        = string
}

variable "container_name" {
  type        = string
  default     = "appcontainer"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "Dev"
    CreatedBy   = "Terraform"
  }
}