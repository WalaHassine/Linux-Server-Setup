cat > docs/01_user_setup.md << 'EOF'
# 01 — Non-Root User Setup

## Purpose

Direct root login on a server is a significant security risk.
This document explains why a non-root sudo user is required and
walks through every command used in `scripts/01_create_user.sh`.

---

## Why Avoid Direct Root Login?

| Risk | Explanation |
|------|-------------|
| No audit trail | Actions taken as root are harder to attribute to individuals |
| No safety net | A typo as root (`rm -rf /etc`) has immediate, irreversible consequences |
| Wider attack surface | Brute-force attacks target root by default; disabling it reduces exposure |
| Principle of least privilege | Users should only escalate when genuinely needed, not operate elevated by default |

---

## Command-by-Command Breakdown

### 1. Input validation
```bash
if [[ $# -lt 1 || -z "${1}" ]]; then
  echo "ERROR: No username supplied." >&2
  exit 1
fi
```
Ensures the script always receives a USERNAME argument.
Printing errors to stderr (`>&2`) keeps stdout clean for piping.
`exit 1` signals failure to any calling process or CI runner.

---

### 2. Root check
```bash
if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: This script must be run as root." >&2
  exit 1
fi
```
`$EUID` is the effective user ID. 0 = root.
User and group management commands require root — failing fast
here avoids confusing permission errors mid-script.

---

### 3. Create the user
```bash
useradd --create-home --shell /bin/bash "$USERNAME"
```
| Flag | Purpose |
|------|---------|
| `--create-home` | Creates `/home/<USERNAME>` — required for a usable login environment |
| `--shell /bin/bash` | Sets bash as the default shell explicitly |

The `id` pre-check prevents the script from failing if re-run on
an existing user (idempotency).

---

### 4. Set a password
```bash
passwd "$USERNAME"
```
Prompts interactively for a password. Without a password the account
is locked and the user cannot log in via the console or SSH
with password authentication.

---

### 5. Add to sudo group
```bash
usermod --append --groups sudo "$USERNAME"
```
| Flag | Purpose |
|------|---------|
| `--append` | Adds to the group without removing existing group memberships |
| `--groups sudo` | The `sudo` group on Ubuntu grants full sudo access via `/etc/sudoers` |

**Why not edit `/etc/sudoers` directly?**
The `sudo` group is the Ubuntu convention. Editing sudoers
manually risks syntax errors that can lock out all admin access.

---

### 6. Verify membership
```bash
id "$USERNAME" | grep -q "(sudo)"
```
`id` prints all group memberships for a user.
Grepping for `(sudo)` confirms the `usermod` command took effect.
The script exits with an error if the check fails — never silently
proceeding in a broken state.

---

## Usage

```bash
sudo bash scripts/01_create_user.sh <USERNAME>
```

### Example
```bash
sudo bash scripts/01_create_user.sh alice
```

Expected output:
OK: User 'alice' created.
Set a password for 'alice':
New password:
Retype new password:
passwd: password updated successfully
OK: 'alice' added to sudo group.
OK: Verified — id output: uid=1001(alice) gid=1001(alice) groups=1001(alice),27(sudo)
=================================================================
Done. Log in as 'alice' and run: sudo -l to confirm access.
---

## Post-Setup Verification (manual)

After running the script, switch to the new user and confirm sudo works:

```bash
su - <USERNAME>
sudo -l          # should list allowed commands
sudo whoami      # should print: root
```

---

## What This Script Does NOT Touch

- SSH configuration — handled in issues #3 and #4
- Firewall rules — handled in a later issue
- SSH key setup — handled in a later issue