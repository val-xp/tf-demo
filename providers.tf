provider "azurerm" {
  features {}
  skip_provider_registration = true
}

provider "random" {
}

provider "databricks" {
  host = azurerm_databricks_workspace.example.workspace_url
}