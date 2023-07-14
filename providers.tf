provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "databricks" {
  host = azurerm_databricks_workspace.example.workspace_url
  azure_workspace_resource_id = azurerm_databricks_workspace.example.id
}