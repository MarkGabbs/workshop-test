ansible-galaxy collection install ansible.windows


ansible-playbook -i inventory.ini enable-rdp.yml
	or with a limit
ansible-playbook -i inventory.ini enable-rdp.yml --limit win01.example.com

# Preview only
ansible-playbook -i inventory windows_updates.yml --check

# Apply updates
ansible-playbook -i inventory windows_updates.yml

category_names:
  - SecurityUpdates
  - CriticalUpdates
  - UpdateRollups

become: true
become_method: runas
become_user: SYSTEM














