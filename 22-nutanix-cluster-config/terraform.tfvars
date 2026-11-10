# Example terraform.tfvars
# Copy to terraform.tfvars and fill in real values. Do NOT commit secrets.

nutanix_username     = "admin"
nutanix_password     = "your-pc-password"
nutanix_endpoint     = "10.x.x.x"          # Prism Central IP/FQDN
nutanix_port         = "9440"

cluster_name         = "YourNewClusterName"

data_services_ip     = "10.11.230.10"      # Actual Data Services IP

ad_domain            = "nutanix.wei"
ad_ldap_url          = "ldap://dc01.nutanix.wei:389"
ad_bind_username     = "nutanix.prism@nutanix.wei"
ad_bind_password     = "your-bind-password"

ad_group_name        = "Nutanix Admins"
ad_group_dn          = "CN=Nutanix Admins,OU=Groups,DC=nutanix,DC=wei"
