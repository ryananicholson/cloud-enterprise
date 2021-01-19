resource "azurerm_virtual_desktop_host_pool" "vdi_pool" {
  name                = "${var.org_name}-pool"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name

  type               = "Pooled"
  load_balancer_type = "BreadthFirst"
}

resource "azurerm_virtual_desktop_application_group" "desktopapp" {
  name                = "${var.org_name}-desktop"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name

  type          = "Desktop"
  host_pool_id  = azurerm_virtual_desktop_host_pool.vdi_pool.id
  friendly_name = "${var.org_name}AppGroup"
  description   = "${var.org_name} Application Group"
}

resource "azurerm_virtual_desktop_workspace" "cent_workspace" {
  name                = "${var.org_name}-workspace"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name

  friendly_name = "${var.org_name}Workspace"
  description   = "${var.org_name} Workspace"
}

resource "azurerm_virtual_desktop_workspace_application_group_association" "workspaceremoteapp" {
  workspace_id         = azurerm_virtual_desktop_workspace.cent_workspace.id
  application_group_id = azurerm_virtual_desktop_application_group.desktopapp.id
}
