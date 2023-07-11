data "azurerm_client_config" "current" {
}

// key vault used as backend for a Databricks secret scope
resource "azurerm_key_vault" "this" {
  name                     = "${local.prefix}-kv"
  location                 = azurerm_resource_group.dp_rg.location
  resource_group_name      = azurerm_resource_group.dp_rg.name
  tenant_id                = data.azurerm_client_config.current.tenant_id
  //soft_delete_enabled      = false
  purge_protection_enabled = true
  enabled_for_disk_encryption = true
  sku_name                 = "standard"
}

// current user (the user launching terraform command) access to key vault secrets and keys
resource "azurerm_key_vault_access_policy" "this" {
  key_vault_id       = azurerm_key_vault.this.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id  
  key_permissions    = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore"]
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}
