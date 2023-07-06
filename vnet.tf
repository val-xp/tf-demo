resource "azurerm_virtual_network" "this" {
  name                = "${local.prefix}-vnet"
  location            = azurerm_resource_group.dp_rg.location
  resource_group_name = azurerm_resource_group.dp_rg.name
  address_space       = [var.cidr]
  tags                = local.tags
}

resource "azurerm_network_security_group" "this" {
  name                = "${local.prefix}-nsg"
  location            = azurerm_resource_group.dp_rg.location
  resource_group_name = azurerm_resource_group.dp_rg.name
  tags                = local.tags
}

resource "azurerm_subnet" "public" {
  name                 = "${local.prefix}-public"
  resource_group_name  = azurerm_resource_group.dp_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.cidr, 3, 0)]

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.this.id
}

variable "private_subnet_endpoints" {
  default = []
}

resource "azurerm_subnet" "private" {
  name                 = "${local.prefix}-private"
  resource_group_name  = azurerm_resource_group.dp_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.cidr, 3, 1)]

  private_endpoint_network_policies_enabled = true
  private_link_service_network_policies_enabled = true
  service_endpoints = var.private_subnet_endpoints

  delegation {
    name = "databricks"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
      "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }

}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_subnet" "dp_plsubnet" {
  name                                           = "${local.prefix}-dp-privatelink"
  resource_group_name                            = azurerm_resource_group.dp_rg.name
  virtual_network_name                           = azurerm_virtual_network.this.name
  address_prefixes                               = [cidrsubnet(var.cidr, 3, 2)]
  private_endpoint_network_policies_enabled = true
  //private_link_service_network_policies_enabled = true
} 

module "nat_gateway" {
  source                         = "./nat_gateway"
  rg_name                        = azurerm_resource_group.dp_rg.name
  location                       = var.location
  nat_gateway_name               = local.nat_gateway_name
  nat_sku_name                   = "Standard"
  pip_name                       = "pip-nat-${local.prefix}" 
  pip_allocation_methode         = "Static"
  pip_sku                        = "Standard"
  nat_gateway_associated_subnets = []
  depends_on                     = [azurerm_virtual_network.this]
}

resource "azurerm_subnet_nat_gateway_association" "nat_subnet_assc_pu" {
  subnet_id             = azurerm_subnet.public.id
  nat_gateway_id        = module.nat_gateway.nat_gateway_id
  depends_on            = [module.nat_gateway]
}
resource "azurerm_subnet_nat_gateway_association" "nat_subnet_assc_pr" {
  subnet_id             = azurerm_subnet.private.id
  nat_gateway_id        = module.nat_gateway.nat_gateway_id
  depends_on            = [module.nat_gateway]
}

resource "azurerm_subnet" "hubfw" {
  //name must be fixed as AzureFirewallSubnet
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.dp_rg.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [cidrsubnet(var.cidr, 3, 3)]
}