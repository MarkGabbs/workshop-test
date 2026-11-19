# Nutanix Cluster Configuration Terraform

This configuration configures a newly added Nutanix cluster registered to Prism Central.

## Features Covered
- Data Services IP (`external_data_services_ip`)
- Subnets:
  - `10.11.230.0/24` VLAN 1330
  - `10.11.231.0/24` Host/CVM VLAN 0
- LCM auto-inventory + NCC Auto-Update (`has_module_auto_upgrade_enabled`)
- AD LDAP (non-LDAPS, non-recursive) with bind account `nutanix.prism@nutanix.wei`
- AD Group `Nutanix Admins` assigned Cluster Admin role via Authorization Policy
- Domain awareness set to RACK (adjust for single-rack placement)

## Not Fully Automated in Provider (as of recent versions)
- **Manage VM High Availability Reservation**: Enable in PE UI or via `acli ha.update`.
- **Rebuild Capacity Reservation**: Enable in PE Settings > Data Resiliency.
- Full Rack Configuration (assigning specific nodes/blocks to a named rack): May require PE Rack Configuration UI or additional node metadata during expansion. Single-rack setups commonly use NODE or BLOCK domain awareness.

## Usage
1. Copy `terraform.tfvars.example` to `terraform.tfvars` and update values.
2. Ensure the cluster is registered to PC and you have admin credentials.
3. If managing an existing cluster:
   ```bash
   terraform init
   terraform import nutanix_cluster_v2.configure_cluster <cluster-ext-id>
   ```
4. `terraform plan` / `terraform apply`

## Prerequisites
- Prism Central with the cluster registered
- Appropriate permissions
- Latest Nutanix Terraform provider (>= 2.3.x recommended)
- AD reachable via LDAP from PC

Review and adjust IPs, gateways, DNs, and domain awareness before applying.
