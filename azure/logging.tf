resource "azurerm_log_analytics_workspace" "cent_workspace" {
  name                = "${var.org_name}-workspace"
  location            = azurerm_resource_group.cent_rg.location
  resource_group_name = azurerm_resource_group.cent_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_datasource_windows_event" "application" {
  name                = "${var.org_name}-application"
  resource_group_name = azurerm_resource_group.cent_rg.name
  workspace_name      = azurerm_log_analytics_workspace.cent_workspace.name
  event_log_name      = "Application"
  event_types         = ["error", "warning", "information"]
}

resource "azurerm_log_analytics_datasource_windows_event" "powershell" {
  name                = "${var.org_name}-powershell"
  resource_group_name = azurerm_resource_group.cent_rg.name
  workspace_name      = azurerm_log_analytics_workspace.cent_workspace.name
  event_log_name      = "Microsoft-Windows-PowerShell/Operational"
  event_types         = ["error", "warning", "information"]
}

resource "azurerm_log_analytics_datasource_windows_event" "system" {
  name                = "${var.org_name}-system"
  resource_group_name = azurerm_resource_group.cent_rg.name
  workspace_name      = azurerm_log_analytics_workspace.cent_workspace.name
  event_log_name      = "System"
  event_types         = ["error", "warning", "information"]
}
