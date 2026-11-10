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
  endpoint = var.nutanix_endpoint
  password = var.nutanix_password
  port     = 9440
  insecure = true
}

variable "nutanix_username" {
  description = "Prism Central username"
  type        = string
}

variable "nutanix_password" {
  description = "Prism Central password"
  type        = string
  sensitive   = true
}

variable "nutanix_endpoint" {
  description = "Prism Central IP or FQDN"
  type        = string
}

locals {
  category_key    = "AAA-Terraform"
  category_values = ["prod", "dev", "test"]
}

resource "nutanix_category_v2" "environment" {
  for_each    = toset(local.category_values)
  key         = local.category_key
  value       = each.value
  description = "Environment category value: ${each.value}"
}





































