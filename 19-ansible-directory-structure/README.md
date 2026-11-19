ansible-playbook -i inventory.ini enable-rdp.yml
	or with a limit
ansible-playbook -i inventory.ini enable-rdp.yml --limit win01.example.com




ansible-baseline/
├── ansible.cfg
├── inventory/					# Pretty much universal
│   ├── inventory.ini			# or hosts.yml or hosts.yaml
│   ├── group_vars/				# OS-specific variables (winrm, become, ntp server, etc.)
│   │   ├── all.yml
│   │   ├── windows.yml
│   │   └── linux.yml
│   └── host_vars/			# Use sparingly — only for things that are  unique to 1 host
├── playbooks/
│   ├── windows/				# Clear separation by OS
│   │   ├── enable-rdp.yml
│   │   ├── enable-ping.yml
│   │   ├── add-local-admins.yml
│   │   └── windows-baseline.yml
│   └── linux/					# Clear separation by OS
│       ├── 01-unattended-upgrades.yml
│       ├── 02-ufw-firewall.yml
│       ├── 03-chrony-ntp.yml
│       ├── 04-admin-users.yml
│       ├── 05-hardening.yml
│       └── ubuntu-baseline.yml
├── roles/                     # Reusable, shareable content (expected long-term)
│   └── ...
└── README.md




ansible-playbook playbooks/site-using-roles.yml -K










