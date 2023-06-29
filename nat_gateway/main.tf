resource "azurerm_public_ip" "pip" {
  name                  = var.pip_name
  location              = var.location
  resource_group_name   = var.rg_name
  allocation_method     = var.pip_allocation_methode
  sku                   = var.pip_sku
}

resource "azurerm_nat_gateway" "nat"{
  name                  = var.nat_gateway_name
  location              = var.location
  resource_group_name   = var.rg_name
  sku_name              = var.nat_sku_name
  depends_on            = [azurerm_public_ip.pip]
}

resource "azurerm_nat_gateway_public_ip_association" "nat_pip_assc" {
  nat_gateway_id        = azurerm_nat_gateway.nat.id
  public_ip_address_id  = azurerm_public_ip.pip.id
}
