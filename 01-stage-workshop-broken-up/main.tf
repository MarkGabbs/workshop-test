terraform {
  required_version = ">= 1.5"

  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "~> 2.12"
    }
    dns = {
      source  = "hashicorp/dns"
      version = "~> 3.6"
    }
  }
}

# ---------------------------------------------------------------------------
# Providers
# ---------------------------------------------------------------------------
provider "vsphere" {
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  allow_unverified_ssl = true
}

# GSS-TSIG (Kerberos) for Active Directory DNS
# Prerequisites:
# - Zone allows secure dynamic updates
# - Account has Create/Delete child objects (or is in DnsAdmins)
# - Kerberos works (realm, AES encryption preferred)
provider "dns" {
  update {
    server = var.dns_server
    gssapi {
      realm    = var.dns_realm
      username = var.dns_username
      password = var.dns_password
      # Alternatively use keytab = "/path/to/keytab"
    }
  }
}

# ---------------------------------------------------------------------------
# Data sources
# ---------------------------------------------------------------------------
data "vsphere_datacenter" "dc" {
  name = var.datacenter
}

data "vsphere_datastore" "datastore" {
  name          = var.datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_host" "host" {
  name          = var.vm_host
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
  name          = var.port_group
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "windows_template" {
  name          = var.windows_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "linux_template" {
  name          = var.linux_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

# ---------------------------------------------------------------------------
# Locals – VM definitions (from your CSV)
# ---------------------------------------------------------------------------
locals {
  # Common network settings
  subnet_mask = 24
  gateway     = "10.11.242.1"
  dns_servers = ["10.11.242.11", "10.11.242.12"]
  domain      = "vmware.wei"

  # Windows VMs
  windows_vms = {
    "student00" = { ip = "10.11.242.130" }
    "student01" = { ip = "10.11.242.131" }
    "student02" = { ip = "10.11.242.133" }
    "student03" = { ip = "10.11.242.135" }
    "student04" = { ip = "10.11.242.137" }
    "student05" = { ip = "10.11.242.139" }
    "student06" = { ip = "10.11.242.141" }
    "student07" = { ip = "10.11.242.143" }
    "student08" = { ip = "10.11.242.145" }
    "student09" = { ip = "10.11.242.147" }
    "student10" = { ip = "10.11.242.149" }
    "student11" = { ip = "10.11.242.151" }
    "student12" = { ip = "10.11.242.153" }
  }

  # Linux VMs
  linux_vms = {
    "student01-linux" = { ip = "10.11.242.132" }
    "student02-linux" = { ip = "10.11.242.134" }
    "student03-linux" = { ip = "10.11.242.136" }
    "student04-linux" = { ip = "10.11.242.138" }
    "student05-linux" = { ip = "10.11.242.140" }
    "student06-linux" = { ip = "10.11.242.142" }
    "student07-linux" = { ip = "10.11.242.144" }
    "student08-linux" = { ip = "10.11.242.146" }
    "student09-linux" = { ip = "10.11.242.148" }
    "student10-linux" = { ip = "10.11.242.150" }
    "student11-linux" = { ip = "10.11.242.152" }
    "student12-linux" = { ip = "10.11.242.154" }
  }

  # DNS records (A records – student00 excluded, matching your dns-entries.csv)
  dns_records = merge(
    { for k, v in local.windows_vms : k => v.ip if k != "student00" },
    { for k, v in local.linux_vms : k => v.ip }
  )

  # Reverse zone for 10.11.242.0/24
  reverse_zone = "242.11.10.in-addr.arpa."
}

# ---------------------------------------------------------------------------
# Windows VMs
# ---------------------------------------------------------------------------
resource "vsphere_virtual_machine" "windows" {
  for_each = local.windows_vms

  name             = each.key
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  host_system_id   = data.vsphere_host.host.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder

  num_cpus = 2
  memory   = 8192

  guest_id  = data.vsphere_virtual_machine.windows_template.guest_id
  scsi_type = data.vsphere_virtual_machine.windows_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.windows_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.windows_template.disks[0].size
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.windows_template.id

    customize {
      windows_options {
        computer_name = each.key
        # Uncomment and fill if you want domain join (your original specs may already do this)
        # join_domain           = local.domain
        # domain_admin_user     = "administrator"
        # domain_admin_password = var.domain_admin_password
      }

      network_interface {
        ipv4_address    = each.value.ip
        ipv4_netmask    = local.subnet_mask
        dns_server_list = local.dns_servers
      }

      ipv4_gateway = local.gateway
    }
  }

  # Optional: power on after clone
  # power_on = true  # default is true
}

# ---------------------------------------------------------------------------
# Linux VMs
# ---------------------------------------------------------------------------
resource "vsphere_virtual_machine" "linux" {
  for_each = local.linux_vms

  name             = each.key
  resource_pool_id = data.vsphere_host.host.resource_pool_id
  host_system_id   = data.vsphere_host.host.id
  datastore_id     = data.vsphere_datastore.datastore.id
  folder           = var.vm_folder

  num_cpus = 2
  memory   = 8192

  guest_id  = data.vsphere_virtual_machine.linux_template.guest_id
  scsi_type = data.vsphere_virtual_machine.linux_template.scsi_type

  network_interface {
    network_id   = data.vsphere_network.network.id
    adapter_type = data.vsphere_virtual_machine.linux_template.network_interface_types[0]
  }

  disk {
    label            = "disk0"
    size             = data.vsphere_virtual_machine.linux_template.disks[0].size
    thin_provisioned = true
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.linux_template.id

    customize {
      linux_options {
        host_name = each.key
        domain    = local.domain
      }

      network_interface {
        ipv4_address = each.value.ip
        ipv4_netmask = local.subnet_mask
      }

      ipv4_gateway    = local.gateway
      dns_server_list = local.dns_servers
    }
  }
}

# ---------------------------------------------------------------------------
# Active Directory DNS A records
# ---------------------------------------------------------------------------
resource "dns_a_record_set" "student_records" {
  for_each = local.dns_records

  zone      = "${local.domain}."
  name      = each.key
  addresses = [each.value]
  ttl       = 3600
}

# ---------------------------------------------------------------------------
# Active Directory DNS PTR records (reverse lookup)
# ---------------------------------------------------------------------------
resource "dns_ptr_record" "student_ptr_records" {
  for_each = local.dns_records

  zone = local.reverse_zone
  name = split(".", each.value)[3]   # last octet, e.g. 131 for 10.11.242.131
  ptr  = "${each.key}.${local.domain}."
  ttl  = 3600
}

# Optional: outputs
output "windows_vm_ips" {
  value = { for k, v in vsphere_virtual_machine.windows : k => v.default_ip_address }
}

output "linux_vm_ips" {
  value = { for k, v in vsphere_virtual_machine.linux : k => v.default_ip_address }
}
