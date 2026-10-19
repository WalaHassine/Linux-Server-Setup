# Security Configuration Audit Log

## 1) Firewall policy
- **Chosen:** UFW with `deny incoming`, `allow outgoing`, and explicit `22/tcp` allow.
- **Why:** Keeps SSH reachable while blocking all unsolicited inbound traffic by default.
- **Alternatives considered:** iptables/nftables direct rule authoring (more flexible but higher operational complexity for baseline setup).

## 2) Automatic patching
- **Chosen:** `unattended-upgrades` with security origin enabled.
- **Why:** Applies security fixes continuously with low operational overhead.
- **Alternatives considered:** manual monthly patch windows (higher drift and delayed remediation).

## 3) Brute-force protection
- **Chosen:** Fail2Ban SSH jail (`maxretry=5`, `findtime=600`, `bantime=3600`).
- **Why:** Detects repeated failed attempts quickly and blocks abusive IPs for meaningful cooldown.
- **Alternatives considered:** static IP allowlisting only (strong but often impractical for roaming administrators).

## 4) SSH authentication model
- **Chosen:** key-based auth with root login disabled and password auth disabled.
- **Why:** Prevents password brute-force and removes direct root login risk.
- **Alternatives considered:** password+MFA (good but requires additional identity tooling not in this baseline repo).

## 5) Time and identity consistency
- **Chosen:** explicit timezone and descriptive hostname via `timedatectl`/`hostnamectl`.
- **Why:** Improves correlation of logs and makes host role clear in monitoring and incident triage.
- **Alternatives considered:** default UTC and cloud-assigned hostnames (acceptable but less operator-friendly for this workflow).

## 6) Logging and verification
- **Chosen:** journalctl + `/var/log` inspection guide with logrotate validation.
- **Why:** Provides repeatable checks for auth failures, service errors, and ban events.
- **Alternatives considered:** GUI log dashboards only (useful later, but CLI-first verification is portable and immediate).

## 7) Service lifecycle management
- **Chosen:** systemctl reference workflow for status/start/restart/enable/is-active with safe stop/disable examples.
- **Why:** Standardizes routine operations while keeping required security services active and enabled.
- **Alternatives considered:** ad-hoc command usage without documentation (inconsistent and harder to audit).
