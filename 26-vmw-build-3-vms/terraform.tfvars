# Common connection variables
vsphere_user     = "administrator@vsphere.local"
vsphere_password = "your-password"
vsphere_server   = "vc11.vmware.wei"

# ---- Plan 1: VMs from regular VM Template ----
datacenter                 = "Datacenter"
cluster                    = "mngt-cluster"
datastore                  = "mngt-cluster"
network                    = "10.11.242.x-24"
template_name              = "w2022"
vm_names                   = ["w2022-01", "w2022-02", "w2022-03"]
# folder                   = "Workloads"
