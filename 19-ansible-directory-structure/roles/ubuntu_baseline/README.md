# Ubuntu Baseline Role

Applies the five baseline configurations for Ubuntu hosts:

1. Unattended security upgrades (Sunday 05:00)
2. UFW firewall (SSH allowed, ping allowed by default)
3. Chrony time sync to internal NTP
4. WEI admin group + users
5. Service and kernel hardening

## Usage

```yaml
- name: Apply Ubuntu baseline
  hosts: linux
  become: true
  roles:
    - ubuntu_baseline
```
