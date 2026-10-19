# 05 — Server Configuration (Timezone, Hostname, Services)

## Set timezone and hostname
Command:
```bash
sudo bash scripts/06_server_config.sh "Africa/Tunis" "prod-web-01"
```

The script:
- validates timezone input
- runs `timedatectl set-timezone "$TIMEZONE"`
- verifies timezone through `timedatectl show --property=Timezone --value`
- runs `hostnamectl set-hostname "$HOSTNAME"`
- ensures `/etc/hosts` maps `127.0.1.1` to the chosen hostname

Why this matters:
- consistent timezone improves incident timeline analysis
- meaningful hostname improves traceability in logs, monitoring, and SSH prompts

Post-reboot verification:
```bash
timedatectl
hostname
hostnamectl --static
```

## systemctl cheat sheet

| Command | Effect | Example |
|---|---|---|
| `systemctl status <service>` | View runtime details and recent logs | `systemctl status ssh` |
| `systemctl start <service>` | Start stopped service immediately | `systemctl start fail2ban` |
| `systemctl stop <service>` | Stop running service immediately | `systemctl stop unattended-upgrades` |
| `systemctl restart <service>` | Restart service to apply changes | `systemctl restart ssh` |
| `systemctl enable <service>` | Start service automatically at boot | `systemctl enable ufw` |
| `systemctl disable <service>` | Prevent auto-start at boot | `systemctl disable ufw` |
| `systemctl is-active <service>` | Return current runtime state | `systemctl is-active ssh` |

Reference script:
```bash
sudo bash scripts/07_service_management.sh
```

The script demonstrates command usage for:
- `ssh`
- `ufw`
- `fail2ban`
- `unattended-upgrades`
