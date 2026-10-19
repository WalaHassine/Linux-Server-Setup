#!/usr/bin/env bash
# =============================================================================
# 07_service_management.sh
# Demonstrates systemctl service management for key hardening services.
# Usage: sudo bash scripts/07_service_management.sh
# =============================================================================

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi

SERVICES=(ssh ufw fail2ban unattended-upgrades)

service_exists() {
  local service="$1"
  systemctl list-unit-files --type=service --no-legend | awk '{print $1}' | grep -Fxq "${service}.service"
}

for service in "${SERVICES[@]}"; do
  if ! service_exists "${service}"; then
    echo "WARN: ${service}.service not found. Skipping gracefully."
    continue
  fi

  echo "=== ${service} ==="
  echo "status:" 
  systemctl status "${service}" --no-pager || true

  echo "start:" 
  systemctl start "${service}"

  echo "restart:" 
  systemctl restart "${service}"

  echo "enable:" 
  systemctl enable "${service}" >/dev/null

  echo "stop (demonstration command, not executed): systemctl stop ${service}"
  echo "disable (demonstration command, not executed): systemctl disable ${service}"

  if ! systemctl is-active --quiet "${service}"; then
    echo "ERROR: ${service} is not active." >&2
    exit 1
  fi

  if ! systemctl is-enabled --quiet "${service}"; then
    echo "ERROR: ${service} is not enabled." >&2
    exit 1
  fi

  echo "is-active: $(systemctl is-active "${service}")"
  echo "is-enabled: $(systemctl is-enabled "${service}")"
done

echo "OK: Service management checks completed."
