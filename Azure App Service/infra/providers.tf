terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
  }

  backend "azurerm" {
    resource_group_name  = "myRG"
    storage_account_name = "sttfstateuat001"
    container_name       = "tfstate"
    key                  = "appservice-uat.tfstate"
  }
}

provider "azurerm" {
  features {}
}

