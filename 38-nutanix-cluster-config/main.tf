# Nutanix Terraform Configuration for Newly Added Cluster
# Provider: nutanix/nutanix (v2.x recommended)
# Assumes the cluster is already created, imaged, and registered to Prism Central.
# This configures post-add settings: Data Services IP, HA/Rebuild reservations (where supported),
# subnets, LCM, Rack (single rack), AD LDAP, and AD Group as Cluster Admin.

terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = ">= 2.3.0"
    }
  }
  required_version = ">= 1.5.0"
}

# Provider configuration - use variables or environment variables for secrets
provider "nutanix" {
  username = var.nutanix_username
  password = var.nutanix_password
  endpoint = var.nutanix_endpoint  # Prism Central IP or FQDN
  port     = var.nutanix_port
  insecure = true  # Set to false in production with valid certs
  wait_timeout = 60
}

# ==================== Variables ====================
variable "nutanix_username" {
  description = "Prism Central username"
  type        = string
  sensitive   = true
}

variable "nutanix_password" {
  description = "Prism Central password"
  type        = string
  sensitive   = true
}

variable "nutanix_endpoint" {
  description = "Prism Central endpoint (IP or FQDN)"
  type        = string
}

variable "nutanix_port" {
  description = "Prism Central port"
  type        = string
  default     = "9440"
}

variable "cluster_name" {
  description = "Name of the newly added cluster"
  type        = string
  default     = "NewCluster"  # Update this
}

variable "data_services_ip" {
  description = "Data Services IP (External Data Services IP) for the cluster"
  type        = string
  default     = "10.11.230.10"  # Example - update
}

variable "ad_domain" {
  description = "Active Directory domain"
  type        = string
  default     = "nutanix.wei"
}

variable "ad_ldap_url" {
  description = "LDAP URL (not LDAPS) for AD"
  type        = string
  default     = "ldap://ad.nutanix.wei:389"  # Update with actual AD host
}

variable "ad_bind_username" {
  description = "AD bind account (service account)"
  type        = string
  default     = "nutanix.prism@nutanix.wei"
}

variable "ad_bind_password" {
  description = "AD bind account password"
  type        = string
  sensitive   = true
}

variable "ad_group_name" {
  description = "AD Group name for Cluster Admin"
  type        = string
  default     = "Nutanix Admins"
}

variable "ad_group_dn" {
  description = "Distinguished Name of the AD Group"
  type        = string
  default     = "CN=Nutanix Admins,OU=Groups,DC=nutanix,DC=wei"  # Update with actual DN
}

# ==================== Data Sources ====================
# Lookup the newly added cluster
data "nutanix_clusters_v2" "target_cluster" {
  filter = "name eq '${var.cluster_name}'"
}

# Lookup Cluster Admin role (built-in)
data "nutanix_roles_v2" "cluster_admin" {
  filter = "displayName eq 'Cluster Admin'"
}

locals {
  cluster_ext_id = data.nutanix_clusters_v2.target_cluster.cluster_entities[0].ext_id
  cluster_admin_role_id = data.nutanix_roles_v2.cluster_admin.roles[0].ext_id
}

# ==================== Cluster Configuration ====================
# Update cluster: Data Services IP, fault tolerance / domain awareness
# Note: Full rack configuration (assigning nodes to racks) may require additional
# PE-side steps or cluster_add_node details. Setting domain_awareness_level to RACK
# for rack-aware FT. For "all nodes in a single rack", typically use NODE or BLOCK
# awareness unless multi-rack topology is defined.
resource "nutanix_cluster_v2" "configure_cluster" {
  # Use import or manage existing - for update of existing cluster
  # If the cluster was created outside TF, import it first:
  # terraform import nutanix_cluster_v2.configure_cluster <cluster-ext-id>
  
  ext_id = local.cluster_ext_id  # Or name if supported; adjust based on provider version
  name   = var.cluster_name

  config {
    # Enable desired fault tolerance
    fault_tolerance_state {
      domain_awareness_level = "RACK"  # Or "NODE" / "BLOCK" for single rack setup
      # desired_cluster_fault_tolerance = "CFT_1N_OR_1D"  # Adjust as needed
    }
    # Other config as required
  }

  network {
    external_data_services_ip {
      ipv4 {
        value = var.data_services_ip
      }
    }
    # Add external_address (Cluster VIP) if needed
    # external_address {
    #   ipv4 {
    #     value = "10.11.230.5"
    #   }
    # }
  }

  # Lifecycle to prevent recreation
  lifecycle {
    ignore_changes = [
      nodes,
      # Add other fields that shouldn't force replace
    ]
  }

  depends_on = [data.nutanix_clusters_v2.target_cluster]
}

# ==================== Subnets ====================
# Subnet 1: 10.11.230.x/24 VLAN 1330
resource "nutanix_subnet_v2" "subnet_230" {
  name              = "VLAN-1330-10.11.230"
  description       = "Production/User subnet VLAN 1330"
  cluster_reference = local.cluster_ext_id
  subnet_type       = "VLAN"
  network_id        = 1330

  ip_config {
    ipv4 {
      ip_subnet {
        ip {
          value = "10.11.230.0"
        }
        prefix_length = 24
      }
      default_gateway_ip {
        value = "10.11.230.1"  # Update if different
      }
      # Optional: IP pools
      # pool_list {
      #   start_ip { value = "10.11.230.50" }
      #   end_ip   { value = "10.11.230.200" }
      # }
    }
  }
}

# Subnet 2: 10.11.231.x Host/CVM (VLAN 0 - typically management/backplane or native)
resource "nutanix_subnet_v2" "subnet_host_cvm" {
  name              = "HostCVM-10.11.231-VLAN0"
  description       = "Host and CVM network VLAN 0"
  cluster_reference = local.cluster_ext_id
  subnet_type       = "VLAN"
  network_id        = 0

  ip_config {
    ipv4 {
      ip_subnet {
        ip {
          value = "10.11.231.0"
        }
        prefix_length = 24
      }
      default_gateway_ip {
        value = "10.11.231.1"  # Update if different
      }
    }
  }
}

# ==================== LCM Configuration ====================
# Enable auto-inventory and NCC Auto-Update (module auto-upgrade)
resource "nutanix_lcm_config_v2" "lcm_auto" {
  x_cluster_id                 = local.cluster_ext_id
  is_auto_inventory_enabled    = true
  auto_inventory_schedule      = "03:00"  # Default or customize
  has_module_auto_upgrade_enabled = true  # Enables NCC Auto-Update
}

# ==================== Active Directory (LDAP) ====================
# Configure AD via LDAP (not LDAPS), non-recursive, bind account
resource "nutanix_directory_services_v2" "ad_ldap" {
  name           = "AD-${var.ad_domain}"
  url            = var.ad_ldap_url
  directory_type = "ACTIVE_DIRECTORY"
  domain_name    = var.ad_domain
  group_search_type = "NON_RECURSIVE"

  service_account {
    username = var.ad_bind_username
    password = var.ad_bind_password
  }
}

# Import / create the AD Group in Nutanix
resource "nutanix_user_groups_v2" "nutanix_admins" {
  group_type         = "LDAP"
  idp_id             = nutanix_directory_services_v2.ad_ldap.ext_id
  name               = var.ad_group_name
  distinguished_name = var.ad_group_dn

  depends_on = [nutanix_directory_services_v2.ad_ldap]
}

# Authorization Policy: Assign Nutanix Admins group to Cluster Admin role
# Full access to the cluster (adjust entities for scoping if needed)
resource "nutanix_authorization_policy_v2" "cluster_admin_policy" {
  display_name              = "Nutanix-Admins-Cluster-Admin"
  description               = "Assigns Nutanix Admins AD group to Cluster Admin role"
  authorization_policy_type = "USER_DEFINED"
  role                      = local.cluster_admin_role_id

  identities {
    reserved = jsonencode({
      "user" = {
        "group" = {
          "anyof" = [nutanix_user_groups_v2.nutanix_admins.ext_id]
        }
      }
    })
  }

  entities {
    reserved = jsonencode({
      "*" = {
        "*" = {
          "eq" = "*"
        }
      }
    })
  }

  depends_on = [
    nutanix_user_groups_v2.nutanix_admins,
    data.nutanix_roles_v2.cluster_admin
  ]
}

# ==================== Notes on HA & Rebuild Capacity ====================
# Manage VM High Availability Reservation and Rebuild Capacity Reservation
# are primarily Prism Element (PE) settings.
# They can be enabled via:
# - PE UI: Settings > Manage VM High Availability (Enable HA Reservation)
# - PE UI: Settings > Data Resiliency > Rebuild Capacity Reservation
# - Or acli commands on CVM:
#   acli ha.update reservation_type=kAcropolisHAReserveSegments num_host_failures_to_tolerate=1
# For Rebuild Capacity, enable via UI or corresponding API if exposed.
# As of current provider versions, these are not fully managed by nutanix_cluster_v2.
# Recommend post-apply verification or supplemental automation (e.g., Ansible/Nutanix API).

# Outputs
output "cluster_ext_id" {
  value = local.cluster_ext_id
}

output "directory_service_id" {
  value = nutanix_directory_services_v2.ad_ldap.ext_id
}

output "ad_group_id" {
  value = nutanix_user_groups_v2.nutanix_admins.ext_id
}
