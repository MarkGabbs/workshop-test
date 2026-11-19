# Terraform configuration to create a subscribed Content Library
# Subscribes to a published library on vc01.lab.wei
# Pulls all images, OVAs, and templates (on_demand = false, automatic_sync = true)

terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "~> 2.11"
    }
  }
  required_version = ">= 1.5.0"
}

provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# ---------------------------------------------------------------------------
# Variables – adjust these for your environment
# ---------------------------------------------------------------------------
variable "vsphere_user" {
  description = "vSphere username"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server hostname or IP"
  type        = string
}

variable "datacenter" {
  description = "Name of the datacenter"
  type        = string
  default     = "DC1"
}

variable "datastore" {
  description = "Name of the datastore to back the subscribed library"
  type        = string
  default     = "vsanDatastore"
}

variable "library_name" {
  description = "Name for the new subscribed Content Library"
  type        = string
  default     = "Subscribed-from-vc01"
}

variable "subscription_url" {
  description = <<-EOT
    Full subscription URL of the published Content Library on vc01.lab.wei.
    Format is typically:
    https://vc01.lab.wei/cls/vcsp/lib/<library-uuid>/lib.json
    You can find this URL in the published library's settings in vCenter.
  EOT
  type        = string
}

variable "subscription_password" {
  description = "Password for the subscription (if the published library requires authentication). Leave empty for none."
  type        = string
  default     = ""
  sensitive   = true
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "ds" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ---------------------------------------------------------------------------
# Subscribed Content Library
# ---------------------------------------------------------------------------
resource "vsphere_content_library" "subscribed" {
  name            = var.library_name
  description     = "Subscribed Content Library from vc01.lab.wei – downloads all items"
  storage_backing = [data.vsphere_datastore.ds.id]

  subscription {
    subscription_url     = var.subscription_url
    authentication_method = var.subscription_password != "" ? "BASIC" : "NONE"
    password             = var.subscription_password != "" ? var.subscription_password : null
    automatic_sync       = true
    on_demand            = false   # false = download all content immediately
  }
}





































