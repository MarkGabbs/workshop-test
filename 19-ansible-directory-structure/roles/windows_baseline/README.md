# Windows Baseline Role

Applies the three baseline configurations for Windows hosts:

1. Enable Remote Desktop (RDP) + firewall rules + optional NLA
2. Allow ping (ICMP echo request)
3. Add AD user and group to local Administrators

## Usage

```yaml
- name: Apply Windows baseline
  hosts: windows
  become: false
  roles:
    - windows_baseline
```
