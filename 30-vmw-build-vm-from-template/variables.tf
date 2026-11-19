# ---------------------------------------------------------------------------
# Provider and connection
# ---------------------------------------------------------------------------
variable "vsphere_user" {
  description = "vSphere username (e.g. administrator@vsphere.local)"
  type        = string
}

variable "vsphere_password" {
  description = "vSphere password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vSphere server hostname or IP address"
  type        = string
}

# ---------------------------------------------------------------------------
# Infrastructure location
# ---------------------------------------------------------------------------
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

variable "folder" {
  description = "VM folder path (leave empty for no folder / root)"
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Template and customization
# ---------------------------------------------------------------------------
variable "template_name" {
  description = "Name of the VM Template (regular template, not Content Library)"
  type        = string
}

variable "customization_spec_name" {
  description = "Name of the existing Guest Customization Specification"
  type        = string
  default     = "w2022-10.11.242.x"
}

# ---------------------------------------------------------------------------
# VM configuration
# ---------------------------------------------------------------------------
variable "vm_names" {
  description = "List of names for the VMs to create"
  type        = list(string)
  default     = ["vm-01", "vm-02", "vm-03"]
}

variable "num_cpus" {
  description = "Number of vCPUs per VM"
  type        = number
  default     = 2
}

variable "memory" {
  description = "Memory (MB) per VM"
  type        = number
  default     = 4096
}

variable "additional_disk_size" {
  description = "Size (GB) of the additional thin-provisioned data disk"
  type        = number
  default     = 200
}