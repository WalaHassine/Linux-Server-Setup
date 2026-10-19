# 04 — Updates and Security Hardening

## A) Full system package update
Run:
```bash
sudo bash scripts/04a_system_update.sh
```

What it does:
- `apt-get update -y`
- `apt-get upgrade -y`
- `apt-get autoremove -y`
- writes detailed output to `logs/upgrade_<YYYY-MM-DD>.log`

Why:
- Reduces known vulnerabilities before additional hardening
- Keeps baseline packages current before enabling automation

## B) Automatic security patching with unattended-upgrades
Run:
```bash
sudo bash scripts/04b_unattended_upgrades.sh
```

Configuration files:
- `configs/20auto-upgrades`
- `configs/50unattended-upgrades`

Key choices:
- `Update-Package-Lists "1"` and `Unattended-Upgrade "1"` for daily automatic checks and security updates
- allowed origins include `${distro_id}:${distro_codename}-security`

Verification:
```bash
systemctl is-active unattended-upgrades
sudo unattended-upgrade --dry-run --debug
```

## C) Fail2Ban SSH brute-force protection
Run:
```bash
sudo bash scripts/05_fail2ban.sh
```

Jail configuration (`configs/jail.local`):
- `maxretry = 5`
- `findtime = 600`
- `bantime = 3600`

Rationale:
- 5 failures in 10 minutes indicates likely brute-force behavior
- 1-hour ban slows repeated attack attempts without creating long-term lockout

Verification:
```bash
systemctl is-active fail2ban
sudo fail2ban-client status sshd
```
