# Common connection variables
# NOTE: Prefer setting sensitive values via environment variables (TF_VAR_vsphere_password)
# or a secrets manager rather than committing them to source control.
vsphere_user     = "administrator@vsphere.local"
vsphere_password = "your-password" # Replace or use TF_VAR_vsphere_password
vsphere_server   = "vc11.vmware.wei"

# Infrastructure location
datacenter = "Datacenter"
cluster    = "mngt-cluster"
datastore  = "mngt-cluster"
network    = "10.11.242.x-24"
folder     = "" # Leave empty or set to a folder path, e.g. "Workloads"

# Template and customization
template_name           = "w2022"
customization_spec_name = "w2022-10.11.242.x"

# VM configuration
vm_names             = ["w2022-01", "w2022-02", "w2022-03"]
num_cpus             = 2
memory               = 4096
additional_disk_size = 200