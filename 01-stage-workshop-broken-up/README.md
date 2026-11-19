# Terraform configuration for class environment
# Deploys Windows + Linux student VMs and creates AD DNS A records

# Terraform only reads and acts on:
# .tf / .tf.json files (configuration)
# .tfvars / .tfvars.json files (variable values)
# ...hence why it's safe to have the PowerShell scripts in the same directory....


## Prerequisites

1. **vSphere**
   - Templates `w2022` and `ubuntu-server-26.04` exist.
   - Folder `IaC and CaC Workshop` exists (or create it first).
   - Port group `10.11.242.x-24`, datastore `mngt-cluster`, host `esx11.vmware.wei` exist.

2. **Active Directory DNS**
   - Zone `vmware.wei` allows **secure only** dynamic updates.
   - Service account has permissions to create/delete records (DnsAdmins or equivalent).
   - Kerberos authentication works from the machine running Terraform.

3. **Terraform**
   - Terraform >= 1.5
   - Network access to vCenter and the Domain Controller.

## Usage

1. Create a `terraform.tfvars` file (do **not** commit it):

```hcl
vsphere_user     = "administrator@vmware.wei"
vsphere_password = "yourPassword"

dns_username = "svc-terraform"
dns_password = "yourPassword"
```

2. Initialize and apply:

```bash
terraform init
terraform plan
terraform apply
```

## Notes

- **Customization**: Explicit static IP, hostname, and DNS are set in the `customize` block (same end result as your temporary OSCustomizationSpec approach).
- **Domain join**: Commented out in the Windows resource. Uncomment and supply credentials if your original customization specs joined the domain and you want the same behavior.
- **PTR records**: Created in the reverse zone `242.11.10.in-addr.arpa.` (for the 10.11.242.0/24 network). Make sure this reverse lookup zone exists and allows secure dynamic updates.
- **Power on**: VMs power on by default after creation.

## Files

- `main.tf` – Providers, data sources, VM resources, DNS resources
- `variables.tf` – All configurable values with defaults matching your environment

Adjust the defaults in `variables.tf` if any names differ in your lab.
