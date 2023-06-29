
//*********************************
//  General
//*********************************
variable "rg_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Location for the resources"
}

//*********************************
//  PIP
//*********************************
variable "pip_name" {
  type        = string
  description = "Name for public ip"
}

variable "pip_allocation_methode" {
  type        = string
  description = "Allocation method for IP address. Possible values are Static or Dynamic"
  default     = "Static"
}

variable "pip_sku" {
  type        = string
  description = "The SKU of the Public IP. Accepted values are Basic and Standard. Changing this forces a new resource to be created."
  default     = "Basic"
}

//*********************************
//  NAT Gateway
//*********************************

variable "nat_gateway_name" {
  type        = string
  description = "Name for NAT gateway"
}

variable "nat_sku_name" {
  type        = string
  description = "The SKU which should be used. At this time the only supported value is Standard."
  default     = "Standard"
}

variable "nat_gateway_associated_subnets" {
    description = "list of subnets to be associated with NAT Gateway"
    type = any
}

