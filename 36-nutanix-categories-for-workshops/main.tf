terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.5.0"
    }
  }
}

provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint
  port     = 9440
  insecure = true
}

variable "nutanix_username" {
  type = string
}

variable "nutanix_password" {
  type      = string
  sensitive = true
}

variable "nutanix_endpoint" {
  type = string
}

locals {
  categories = {
    AAA-DR = ["Tier0", "Tier1", "Tier2", "Tier3"]
    AAA-ImagePlacement        = ["Dev", "Test", "Prod"]
    AAA-Ops    = ["Dev", "Test", "Prod", "Staging", "UAT", "NewVM", "Domain Controllers"]
    AAA-OraclePlacement = ["Hosts Licensed for Oracle", "VMs running Oracle"]
  }

  # Flatten into a map of "Key:Value" => {key, value}
  category_pairs = {
    for pair in flatten([
      for key, values in local.categories : [
        for value in values : {
          key   = key
          value = value
        }
      ]
    ]) : "${pair.key}:${pair.value}" => pair
  }
}

resource "nutanix_category_v2" "categories" {
  for_each = local.category_pairs

  key         = each.value.key
  value       = each.value.value
  description = "${each.value.key} = ${each.value.value}"
}