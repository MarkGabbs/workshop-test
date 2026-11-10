terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "~> 2.5"
    }
  }
  required_version = ">= 1.5.0"
}