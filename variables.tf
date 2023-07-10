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

variable "workspace_prefix" {
  type    = string
  default = "adb"
}

variable "cidr" {
  type    = string
  default = "10.179.0.0/20"
}

variable "allowed_ips_list" {
  type    = list
}

variable "metastoreip" {
  type = string
}

variable "firewallfqdn" {
  type = list(any)
}

variable "sp_application_id" {
  type = string
}

variable "service_cmk_key" {
  type = string
}

variable "disk_cmk_key" {
  type = string
}

variable "key_vault_id" {
  type = string
}

variable "key_vault_uri" {
  type = string
}
