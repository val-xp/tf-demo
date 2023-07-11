variable "location" {
  type        = string
  description = "(Required) The location for the resources in this module"
}

variable "nameprefix" {
  type        = string
  description = "(Required) string to be used as prefix in the name of rg and workspace"
}

variable "no_public_ip" {
  type    = bool
  default = true
} 

// naming prefix for databricks workspace
variable "workspace_prefix" {
  type    = string
  default = "adb"
}

// Vnet IP cidr
variable "cidr" {
  type    = string
  default = "10.179.0.0/20"
}

// 
variable "allowed_ips_list" {
  type    = list
}

// metastore IP (depends on workspace region, see Azure docs)
variable "metastoreip" {
  type = string
}

// list of whitelisted domains
variable "firewallfqdn" {
  type = list(any)
}

// Application ID of a service principal to be added
variable "sp_application_id" {
  type = string
}

// CMK key vault - key for service communications
variable "service_cmk_key" {
  type = string
}

// CMK key vault - key for disk encryption
variable "disk_cmk_key" {
  type = string
}

// CMK key vault
variable "key_vault_id" {
  type = string
}

// CMK key vault URI
variable "key_vault_uri" {
  type = string
}
