
resource "azurerm_databricks_workspace" "example" {
  name                                  = "${local.prefix}-dp-workspace"
  resource_group_name                   = azurerm_resource_group.dp_rg.name
  location                              = azurerm_resource_group.dp_rg.location
  sku                                   = "premium" // need premium for private link
  tags                                  = local.tags
  public_network_access_enabled         = true // false for frontend private link
  network_security_group_rules_required = "NoAzureDatabricksRules" // backend private link
  customer_managed_key_enabled          = true
  managed_services_cmk_key_vault_key_id = var.service_cmk_key
  managed_disk_cmk_key_vault_key_id     = var.disk_cmk_key
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

// databricks secret scope with secrets saved in Azure key vault
resource "databricks_secret_scope" "kv" {
  name = "keyvault-managed"

  keyvault_metadata {
    resource_id = azurerm_key_vault.this.id
    dns_name    = azurerm_key_vault.this.vault_uri
  }
}

// grant disks to the azure key vault with CMK (customer managed keys)
resource "azurerm_key_vault_access_policy" "mdisks" {
  depends_on = [azurerm_databricks_workspace.example]
  key_vault_id = var.key_vault_id
  tenant_id    = azurerm_databricks_workspace.example.managed_disk_identity.0.tenant_id
  object_id    = azurerm_databricks_workspace.example.managed_disk_identity.0.principal_id
  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
  ]
}