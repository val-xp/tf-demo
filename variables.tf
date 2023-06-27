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

variable "node_type" {
  type    = string
  default = "Standard_DS3_v2"
}

variable "workspace_prefix" {
  type    = string
  default = "adb"
}

variable "global_auto_termination_minute" {
  type    = number
  default = 10
}

variable "cidr" {
  type    = string
  default = "10.179.0.0/20"
}
 
