
resource "azurerm_databricks_workspace" "example" {
  name                                  = "${local.prefix}-dp-workspace"
  resource_group_name                   = azurerm_resource_group.dp_rg.name
  location                              = azurerm_resource_group.dp_rg.location
  sku                                   = "premium" // need premium for private link
  tags                                  = local.tags
  public_network_access_enabled         = true // false for frontend private link
  network_security_group_rules_required = "NoAzureDatabricksRules" // backend private link
  customer_managed_key_enabled          = true
  managed_services_cmk_key_vault_key_id = azurerm_key_vault_key.service.id  
  managed_disk_cmk_key_vault_key_id     = azurerm_key_vault_key.disk.id   
  infrastructure_encryption_enabled     = true

  custom_parameters {
    no_public_ip                                         = var.no_public_ip
    virtual_network_id                                   = azurerm_virtual_network.this.id
    private_subnet_name                                  = azurerm_subnet.private.name // container subnet
    public_subnet_name                                   = azurerm_subnet.public.name // host subnet
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
    storage_account_name                                 = local.dbfsname
  }
  # We need this, otherwise destroy doesn't cleanup things correctly
  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private,
  ]
}

resource "databricks_workspace_conf" "this" {
  custom_config = {
    "enableIpAccessLists" = true
    "enableTokensConfig" = true  
  }
}

resource "databricks_ip_access_list" "ip-list" {
  label     = "ip-list"
  list_type = "ALLOW"  // ALLOW (allow list) or BLOCK (block list)
  ip_addresses = var.allowed_ips_list
  depends_on = [databricks_workspace_conf.this]
}

// Example to add a service principle to the workspace
resource "databricks_service_principal" "sp" {
  application_id = var.sp_application_id
}

resource "databricks_secret_scope" "kv" {
  name = "keyvault-managed"

  keyvault_metadata {
    resource_id = azurerm_key_vault.this.id
    dns_name    = azurerm_key_vault.this.vault_uri
  }
}
