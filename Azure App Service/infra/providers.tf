terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateprod001"
    container_name       = "tfstate"
    key                  = "appservice-prod.tfstate"
  }
}

provider "azurerm" {
  features {}
}

