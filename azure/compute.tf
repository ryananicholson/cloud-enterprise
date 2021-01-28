resource "azurerm_windows_virtual_machine" "wkstn_01" {
  name                = var.wkstn1
  resource_group_name = azurerm_resource_group.cent_rg.name
  location            = azurerm_resource_group.cent_rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.cent_wkstn01_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h1-pro"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "wkstn_02" {
  name                = var.wkstn2
  resource_group_name = azurerm_resource_group.cent_rg.name
  location            = azurerm_resource_group.cent_rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.cent_wkstn02_nic.id,
  ]

  os_disk {              
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h1-pro"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "ad" {
  name                = var.ad
  resource_group_name = azurerm_resource_group.cent_rg.name
  location            = azurerm_resource_group.cent_rg.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = random_password.password.result
  network_interface_ids = [
    azurerm_network_interface.cent_ad_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "linux1" {
  name                = var.linux1
  resource_group_name = azurerm_resource_group.cent_rg.name
  location            = azurerm_resource_group.cent_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  admin_password      = random_password.password.result
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.cent_linux1_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "null_resource" "invoke_ansible" {
  provisioner "local-exec" {
    command = "scripts/configure-systems.sh ${var.org_name}"
  }
  depends_on = [azurerm_windows_virtual_machine.ad, azurerm_windows_virtual_machine.wkstn_01, azurerm_windows_virtual_machine.wkstn_02, azurerm_linux_virtual_machine.linux1, azurerm_log_analytics_workspace.cent_workspace]
}
