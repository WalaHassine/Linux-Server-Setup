# 03 — Firewall Hardening with UFW

## Goal
Enable a deny-by-default firewall while keeping SSH (22/tcp) reachable.

## Primary setup script
```bash
sudo bash scripts/03_configure_ufw.sh
```

## What the script does
1. Installs `ufw`
2. Resets existing rules (`ufw --force reset`)
3. Sets default policy:
   - `deny incoming`
   - `allow outgoing`
4. Adds SSH allow rule (`ufw allow 22/tcp`)
5. Enables UFW and verifies status with `ufw status verbose`

## Why deny-by-default?
- Reduces exposed network surface area
- New services stay blocked until explicitly allowed
- Prevents accidental public exposure after package installs

## Adding future service rules
Use `configs/ufw_rules.sh` as a reference when enabling web traffic:
```bash
sudo bash configs/ufw_rules.sh
```

This adds:
- `80/tcp` for HTTP
- `443/tcp` for HTTPS

## Verification commands
```bash
sudo ufw status
sudo ufw status verbose
```

Expected:
- `Status: active`
- Rule for `22/tcp` present
