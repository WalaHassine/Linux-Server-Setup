#!/usr/bin/env bash
# =============================================================================
# 04b_unattended_upgrades.sh
# Installs and configures unattended-upgrades.
# Usage: sudo bash scripts/04b_unattended_upgrades.sh
# =============================================================================

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y unattended-upgrades ubuntu-advantage-tools

install -m 0644 "${REPO_ROOT}/configs/20auto-upgrades" /etc/apt/apt.conf.d/20auto-upgrades
install -m 0644 "${REPO_ROOT}/configs/50unattended-upgrades" /etc/apt/apt.conf.d/50unattended-upgrades

unattended-upgrade --dry-run --debug
systemctl enable --now unattended-upgrades
systemctl is-active --quiet unattended-upgrades

echo "OK: unattended-upgrades is active and configured."
