provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "cent_rg" {
  name     = var.org_name
  location = "Central US"
}
