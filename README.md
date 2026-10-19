# Linux Server Setup

## Purpose
Automate secure baseline hardening for an Ubuntu server: user setup, SSH hardening, firewall policy, updates, Fail2Ban protection, hostname/timezone configuration, and verification.

---

## Quick start

1. Clone the repository onto your admin machine.
2. Set required variables for scripts that need user/host metadata.
3. Run the full setup pipeline:

```bash
make setup USERNAME=<local-admin-user> REMOTE_USER=<server-user> REMOTE_HOST=<server-ip-or-dns> TIMEZONE=<iana-timezone> HOSTNAME=<server-hostname>
```

4. Validate core hardening state:

```bash
make verify
```

---

## Milestones

- Milestone 1 — Repository Initialization
- Milestone 2 — Environment Setup
- Milestone 3 — Configuration Management
- Milestone 4 — Core Scripts
- Milestone 5 — Security Hardening
- Milestone 6 — Logging & Monitoring
- Milestone 7 — CI/CD Pipeline
- Milestone 8 — Documentation
- Milestone 9 — Final Review & Release
