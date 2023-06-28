resource "azurerm_databricks_workspace" "example" {
  name                                  = "${local.prefix}-dp-workspace"
  resource_group_name                   = azurerm_resource_group.dp_rg.name
  location                              = azurerm_resource_group.dp_rg.location
  sku                                   = "standard"

  tags = local.tags

  custom_parameters {
    no_public_ip                                         = var.no_public_ip
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.private.name
    public_subnet_name                                   = azurerm_subnet.public.name
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    storage_account_name                                 = local.dbfsname
    nat_gateway_name                                     = azurerm_nat_gateway.example.name
  }
  # We need this, otherwise destroy doesn't cleanup things correctly
  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private
  ]
}



