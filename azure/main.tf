provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "cent_rg" {
  name     = var.org_name
  location = "Central US"
}

resource "random_password" "password" {
  length = 16
  special = false
}

resource "null_resource" "update_password" {
  provisioner "local-exec" {
    command = "scripts/update-passwords.sh ${random_password.password.result}"
  }
}
