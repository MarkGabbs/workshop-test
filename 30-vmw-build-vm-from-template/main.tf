# Terraform configuration to create VMs from a regular VM Template
# (not from Content Library)
# Adds a second thin-provisioned hard drive
# Uses an existing Guest Customization Specification

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
  name = var.customization_spec_name
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

  num_cpus  = var.num_cpus
  memory    = var.memory
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

  # Additional thin-provisioned data disk
  disk {
    label            = "Hard Disk 2"
    size             = var.additional_disk_size
    thin_provisioned = true
    unit_number      = 1
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customization_spec {
      id = data.vsphere_guest_os_customization.windows_spec.id
    }
  }

  # Optional: wait for guest network (seconds)
  wait_for_guest_net_timeout = 10
}