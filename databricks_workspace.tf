resource "azurerm_databricks_workspace" "example" {
  name                                  = "${local.prefix}-dp-workspace"
  resource_group_name                   = azurerm_resource_group.dp_rg.name
  location                              = azurerm_resource_group.dp_rg.location
  sku                 = "premium"

  tags = {
    Environment = "Production"
  }
}

