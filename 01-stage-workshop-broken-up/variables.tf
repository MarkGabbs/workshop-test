# ---------------------------------------------------------------------------
# vSphere connection
# ---------------------------------------------------------------------------
variable "vsphere_user" {
  description = "vCenter username"
  type        = string
  sensitive   = true
}

variable "vsphere_password" {
  description = "vCenter password"
  type        = string
  sensitive   = true
}

variable "vsphere_server" {
  description = "vCenter server FQDN or IP"
  type        = string
  default     = "vc11.vmware.wei"
}

# ---------------------------------------------------------------------------
# Environment objects (from your PowerCLI scripts)
# ---------------------------------------------------------------------------
variable "datacenter" {
  type    = string
  default = "Datacenter"
}

variable "datastore" {
  type    = string
  default = "mngt-cluster"
}

variable "vm_host" {
  type    = string
  default = "esx11.vmware.wei"
}

variable "port_group" {
  type    = string
  default = "10.11.242.x-24"
}

variable "vm_folder" {
  description = "VM folder path relative to datacenter/vm"
  type        = string
  default     = "IaC and CaC Workshop"
}

variable "windows_template" {
  type    = string
  default = "w2022"
}

variable "linux_template" {
  type    = string
  default = "ubuntu-server-26.04"
}

# ---------------------------------------------------------------------------
# DNS (Active Directory)
# ---------------------------------------------------------------------------
variable "dns_server" {
  description = "DNS server (Domain Controller) for dynamic updates"
  type        = string
  default     = "dc11.vmware.wei"   # or IP of dc11
}

variable "dns_realm" {
  description = "Kerberos realm / AD domain (uppercase)"
  type        = string
  default     = "VMWARE.WEI"
}

variable "dns_username" {
  description = "Account used for GSS-TSIG DNS updates"
  type        = string
  sensitive   = true
}

variable "dns_password" {
  description = "Password for the DNS update account"
  type        = string
  sensitive   = true
}

# Optional – only needed if you enable domain join in the Windows customize block
variable "domain_admin_password" {
  type      = string
  sensitive = true
  default   = ""
}
