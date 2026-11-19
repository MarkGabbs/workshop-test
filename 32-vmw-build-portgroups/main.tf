# Terraform configuration to create 3 vDS Port Groups
# 10.11.244.x (VLAN 1344)
# 10.11.245.x (VLAN 1345)
# 10.11.246.x (VLAN 1346)
# No custom settings beyond name and VLAN

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
  default     = "Datacenter"
}

variable "dvs_name" {
  description = "Name of the existing Distributed Virtual Switch"
  type        = string
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.dvs_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ---------------------------------------------------------------------------
# Port Groups
# ---------------------------------------------------------------------------
resource "vsphere_distributed_port_group" "pg_244" {
  name                            = "NewPG-01"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = 1346
}

resource "vsphere_distributed_port_group" "pg_245" {
  name                            = "NewPG-02"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = 1346
}

resource "vsphere_distributed_port_group" "pg_246" {
  name                            = "NewPG-03"
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
  vlan_id                         = 1346
}





































