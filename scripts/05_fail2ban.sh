#!/usr/bin/env bash
# =============================================================================
# 05_fail2ban.sh
# Installs and configures Fail2Ban for SSH brute-force protection.
# Usage: sudo bash scripts/05_fail2ban.sh
# =============================================================================

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y fail2ban

install -m 0644 "${REPO_ROOT}/configs/jail.local" /etc/fail2ban/jail.local

systemctl enable --now fail2ban
systemctl is-active --quiet fail2ban

fail2ban-client status sshd

echo "OK: Fail2Ban SSH jail is active."
