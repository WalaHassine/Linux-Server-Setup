# 02 — SSH Hardening
This document covers the full SSH security setup for the Linux server:
generating a key pair locally, deploying the public key to the server,
and disabling password-based authentication.

> **Scope split:**
> - Issue #3 → Key Generation (local machine)
> - Issue #4 → Deployment + Hardening (server side)

---

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

---

## Deployment

Deployment is automated by `scripts/02b_deploy_key.sh`.

### What the script does
1. Validates that the public key and patch file exist locally
2. Runs `ssh-copy-id` to append `~/.ssh/id_ed25519.pub` to `~/.ssh/authorized_keys` on the server
3. Uploads `configs/sshd_config.patch` to `/tmp/` on the server via `scp`
4. Applies the patch with `sudo patch -b` (the `-b` flag creates a `.orig` backup of the original file)
5. Validates the new config with `sudo sshd -t` before restarting — this prevents locking yourself out on a bad config
6. Restarts sshd with `sudo systemctl restart sshd`
7. Confirms `systemctl is-active sshd` returns `active`

**Run it:**
```bash
bash scripts/02b_deploy_key.sh <REMOTE_USER> <REMOTE_HOST>
```

**Example:**
```bash
bash scripts/02b_deploy_key.sh alice 192.168.1.10
```

### Pre-deployment checklist
Before running the script, confirm:
- [ ] You have run `02a_gen_ssh_keys.sh` and a key pair exists at `~/.ssh/id_ed25519`
- [ ] Password-based SSH to the server still works (you need it for the initial `ssh-copy-id`)
- [ ] You have sudo access on the remote server

---

## Hardening

### What `configs/sshd_config.patch` changes

| Directive | Before | After | Why |
|-----------|--------|-------|-----|
| `PasswordAuthentication` | `yes` (default) | `no` | Eliminates brute-force password attacks entirely |
| `PermitRootLogin` | `prohibit-password` | `no` | Prevents any direct root login; use sudo instead |
| `PubkeyAuthentication` | commented out | `yes` | Explicitly enables key-based auth (defence-in-depth) |

### Why `patch -b` instead of `sed`?
- `patch` operates on a diff — the change is reviewable and version-controlled
- `-b` creates `/etc/ssh/sshd_config.orig` automatically — instant rollback with `sudo cp /etc/ssh/sshd_config.orig /etc/ssh/sshd_config`
- `sed` in-place edits are harder to audit and can silently fail on different distro defaults

### Why validate with `sshd -t` before restarting?
A syntax error in `sshd_config` combined with a restart would drop your SSH session and lock you out of the server. `sshd -t` (test mode) parses the config and exits non-zero on errors — the script aborts before touching the running daemon.

### Rollback procedure
If something goes wrong:
```bash
# On the server — restore original config
sudo cp /etc/ssh/sshd_config.orig /etc/ssh/sshd_config
sudo systemctl restart sshd
```

---

## Verifying Key Login (CRITICAL — do before closing your session)

After the script completes, **open a new terminal** and test login before closing the existing session:

```bash
ssh <REMOTE_USER>@<REMOTE_HOST>
```

Expected: login succeeds with no password prompt.

Only close your existing session once this is confirmed. If key login fails while your current session is still open, you can still roll back.

---

## Post-Hardening Verification

```bash
# Confirm password auth is rejected
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no <USER>@<HOST>
# Expected: "Permission denied (publickey)"

# Confirm root login is rejected
ssh root@<HOST>
# Expected: "Permission denied (publickey)" or "root login refused"
```