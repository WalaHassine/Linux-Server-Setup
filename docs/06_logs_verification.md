# 06 — Logs Verification Guide

## journalctl quick checks

### SSH service logs (last hour)
```bash
journalctl -u ssh --since "1 hour ago"
```
Expected format includes timestamp, hostname, and service message lines.

### Recent high-severity events
```bash
journalctl -p err..alert -n 50
```
Expected format shows priority-tagged error/alert messages.

### Follow SSH logs live
```bash
journalctl -u ssh -f
```
Use while testing login or SSH hardening changes.

## /var/log/auth.log checks

### Failed password attempts
```bash
grep "Failed password" /var/log/auth.log
```
Expected output includes source IP and attempted username.

### Successful public-key logins
```bash
grep "Accepted publickey" /var/log/auth.log
```
Expected output includes user, source IP, and key fingerprint details.

### Real-time auth log tail
```bash
tail -n 100 /var/log/auth.log
```
Use to inspect recent authentication flow quickly.

## /var/log/syslog checks

### Show recent system warnings/errors
```bash
grep -E "(error|warning|fail)" /var/log/syslog | tail -n 50
```
Expected output includes subsystem name and failure context.

### Live syslog stream
```bash
tail -f /var/log/syslog
```
Useful during package updates and service restarts.

## /var/log/fail2ban.log checks

### Recent bans/unbans
```bash
tail -n 100 /var/log/fail2ban.log
```
Look for `Ban` and `Unban` events with source IPs.

### Filter only ban actions
```bash
grep " Ban " /var/log/fail2ban.log
```
Shows blocked IP addresses and timestamps.

## logrotate verification

### Dry-run system rotation rules
```bash
logrotate -d /etc/logrotate.conf
```
This validates rotation logic without rotating files.

### Check logrotate schedule
```bash
systemctl status logrotate.timer --no-pager
```
Confirms periodic rotation execution is scheduled.
