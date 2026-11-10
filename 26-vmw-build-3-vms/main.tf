# Terraform configuration to create VMs from a regular VM Template
# (not from Content Library)
# Adds a second 200 GB thin-provisioned hard drive
# Uses existing Guest Customization Specification "w2022-10.11.242.x"

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

variable "cluster" {
  description = "Name of the compute cluster"
  type        = string
  default     = "Cluster1"
}

variable "datastore" {
  description = "Name of the datastore for the VMs"
  type        = string
  default     = "vsanDatastore"
}

variable "network" {
  description = "Name of the port group / network for the VMs"
  type        = string
  default     = "VM Network"
}

variable "template_name" {
  description = "Name of the VM Template (regular template, not Content Library)"
  type        = string
}

variable "vm_names" {
  description = "List of names for the VMs to create"
  type        = list(string)
  default     = ["vm-01", "vm-02", "vm-03"]
}

variable "folder" {
  description = "VM folder path (optional)"
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_compute_cluster" "cluster" {
  name          = var.cluster
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_datastore" "ds" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.network
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
  name          = var.template_name
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_guest_os_customization" "windows_spec" {
  name = "w2022-10.11.242.x"
}

# ---------------------------------------------------------------------------
# Create VMs
# ---------------------------------------------------------------------------
resource "vsphere_virtual_machine" "vms" {
  count = length(var.vm_names)

  name             = var.vm_names[count.index]
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.ds.id
  folder           = var.folder != "" ? var.folder : null

  num_cpus  = 2
  memory    = 4096
  guest_id  = data.vsphere_virtual_machine.template.guest_id
  scsi_type = data.vsphere_virtual_machine.template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = try(data.vsphere_virtual_machine.template.network_interface_types[0], "vmxnet3")
  }

  # First disk (cloned from template)
  disk {
    label            = "Hard Disk 1"
    size             = data.vsphere_virtual_machine.template.disks[0].size
    thin_provisioned = data.vsphere_virtual_machine.template.disks[0].thin_provisioned
    unit_number      = 0
  }

  # Second 200 GB thin-provisioned disk
  disk {
    label            = "Hard Disk 2"
    size             = 200
    thin_provisioned = true
    unit_number      = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customization_spec {
      id = data.vsphere_guest_os_customization.windows_spec.id
    }
  }

  # Optional: wait for guest network
  wait_for_guest_net_timeout = 10
}
