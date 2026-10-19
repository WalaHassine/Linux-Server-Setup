# Security Checklist

- [x] 1. Repository & Access Control
  - Verify: `git remote -v && git branch --show-current`
- [x] 2. Secrets Management
  - Verify: `git grep -nE '(AKIA|SECRET|TOKEN|PASSWORD)'`
- [x] 3. Dependency Security
  - Verify: `bash requirements.sh && apt list --installed | grep -E 'ufw|fail2ban|unattended-upgrades'`
- [x] 4. Authentication & Authorization
  - Verify: `id <USERNAME> && sudo -l -U <USERNAME> && sshd -T | grep -E 'permitrootlogin|passwordauthentication'`
- [x] 5. Network Security
  - Verify: `ufw status verbose`
- [x] 6. Data Encryption
  - Verify: `ssh -Q key | grep ed25519 && ls -l ~/.ssh/id_ed25519*`
- [x] 7. Logging & Monitoring
  - Verify: `journalctl -u ssh --since "1 hour ago" && fail2ban-client status sshd`
- [x] 8. Incident Response Plan
  - Verify: `tail -n 50 /var/log/auth.log && tail -n 50 /var/log/fail2ban.log`
- [x] 9. Final Audit & Sign-off
  - Verify: `make verify && logrotate -d /etc/logrotate.conf`
