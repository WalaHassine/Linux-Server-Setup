# 02 — SSH Hardening
This document covers the full SSH security setup for the Linux server:
generating a key pair locally, deploying the public key to the server,
and disabling password-based authentication.

> **Scope split:**
> - Issue #3 → Key Generation (local machine)
> - Issue #4 → Deployment + Hardening (server side)

## Key Generation

### Why Ed25519?
Ed25519 is the recommended SSH key type. Compared to the older RSA:
- Shorter keys with stronger security
- Faster to generate and verify
- Less prone to implementation vulnerabilities

### Script
Key generation is automated by `scripts/02a_gen_ssh_keys.sh`.

**What the script does:**
1. Checks if `~/.ssh/id_ed25519` already exists — skips if it does (idempotent)
2. Generates an Ed25519 key pair at `~/.ssh/id_ed25519`
3. Prints the public key to stdout for easy copy-paste

**Run it:**
```bash
bash scripts/02a_gen_ssh_keys.sh
```




## Deployment
<!-- Covered by issue #4 — copying public key to server -->

## Hardening
<!-- Covered by issue #4 — disabling password auth in sshd_config -->