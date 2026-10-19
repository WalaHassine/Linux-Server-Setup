#!/usr/bin/env bash
# =============================================================================
# 03_configure_ufw.sh
# Installs and configures UFW with deny-by-default inbound policy and SSH allow.
# Usage: sudo bash scripts/03_configure_ufw.sh
# =============================================================================

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y ufw

ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp
ufw --force enable

STATUS_OUTPUT="$(ufw status verbose)"
echo "${STATUS_OUTPUT}"

grep -q "Status: active" <<<"${STATUS_OUTPUT}" || {
  echo "ERROR: UFW is not active." >&2
  exit 1
}

grep -q "22/tcp" <<<"${STATUS_OUTPUT}" || {
  echo "ERROR: SSH allow rule missing." >&2
  exit 1
}

echo "OK: UFW configured with deny-incoming, allow-outgoing, and SSH allow rule."
