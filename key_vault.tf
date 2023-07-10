data "azurerm_client_config" "current" {
}

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

// databricks app to have access to services keys and secrets
resource "azurerm_key_vault_access_policy" "dbapp" {
  //  depends_on = [azurerm_databricks_workspace.example]
  key_vault_id       = azurerm_key_vault.this.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  // Databricks object id  
  object_id          = "4cc47dc0-9fd1-4903-acaf-1e31a7803047" // Databricks app object id  
  application_id     = "2ff814a6-3304-4ab8-85cb-cd0e6f879c1d"  // Databricks app application id  
  key_permissions    = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Create",
      "UnwrapKey","WrapKey","GetRotationPolicy"]
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers",
    "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover",
    "Restore", "SetIssuers","Update"]
}

// current user key vault policy
resource "azurerm_key_vault_access_policy" "user" {
  key_vault_id       = azurerm_key_vault.this.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id  
  key_permissions    = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Create",
      "UnwrapKey","WrapKey","GetRotationPolicy"]
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
  certificate_permissions = ["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers",
    "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover",
    "Restore", "SetIssuers","Update"]
}

// disks to get access to keys for encryptions
resource "azurerm_key_vault_access_policy" "mdisks" {
  depends_on = [azurerm_databricks_workspace.example]
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = azurerm_databricks_workspace.example.managed_disk_identity.0.tenant_id
  object_id    = azurerm_databricks_workspace.example.managed_disk_identity.0.principal_id
  key_permissions = [
    "Get",
    "UnwrapKey",
    "WrapKey",
    "GetRotationPolicy"
  ]
}

// generate CMK key for services
resource "azurerm_key_vault_key" "service" {
  depends_on = [azurerm_key_vault_access_policy.user]
  name         = "service"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}

// generate CMK key for disk encryption
resource "azurerm_key_vault_key" "disk" {
  depends_on = [azurerm_key_vault_access_policy.user]
  name         = "disk"
  key_vault_id = azurerm_key_vault.this.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}