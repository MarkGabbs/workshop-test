ansible-playbook -i inventory.ini enable-rdp.yml -K
	...the -K is short for --ask-become-pass
	...Ansible will then prompt:
		BECOME password:
	...you then type the sudo password for the ANSIBLE user once
	...and it uses for all hosts in that run
	or with a limit
ansible-playbook -i inventory.ini enable-rdp.yml --limit win01.example.com





ansible-playbook unattended-upgrades.yml -K
ansible-playbook ufw-firewall.yml -K
ansible-playbook ntp.yml -K
ansible-playbook admin-group-users.yml -K
ansible-playbook service-kernel-hardening.yml -K












