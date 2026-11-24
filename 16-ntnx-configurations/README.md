Requirements on each student’s Linux desktop
This would normally be done on the Controller Node, rather than on your desktop.

# Install the official Nutanix collection
ansible-galaxy collection install nutanix.ncp
# If you want to be explicit about Python requests (usually already present)
pip install requests

ansible-playbook create-ntnx-subnets.yaml
