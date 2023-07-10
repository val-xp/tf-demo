terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.13.0"
    }
  }
}

resource "random_string" "naming" {
  // random string for naming (i.e. used in dbfs name)
  special = false
  upper   = false
  length  = 6
}

data "external" "me" {
  program = ["az", "account", "show", "--query", "user"]
}

locals {
  // dltp - databricks labs terraform provider
  prefix   = join("-", ["tfdemo", var.nameprefix])
  dbfsname = join("", ["dbfs", "${random_string.naming.result}"]) // dbfs name must not have special chars
  
  // tags that are propagated down to all resources
  tags = {
    Environment = "Testing"
    Owner       = lookup(data.external.me.result, "name")
    Epoch       = random_string.naming.result
  }
}

resource "azurerm_resource_group" "dp_rg" {
  name     = "adb-dp-${local.prefix}-rg"
  location = var.location
  tags     = local.tags
}

