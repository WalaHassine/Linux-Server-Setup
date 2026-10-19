#!/usr/bin/env bash
# =============================================================================
# 06_server_config.sh
# Sets system timezone and hostname.
# Usage: sudo bash scripts/06_server_config.sh <TIMEZONE> <HOSTNAME>
# =============================================================================

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi

if [[ $# -ne 2 || -z "${1}" || -z "${2}" ]]; then
  echo "Usage: sudo bash $0 <TIMEZONE> <HOSTNAME>" >&2
  exit 1
fi

TIMEZONE="$1"
NEW_HOSTNAME="$2"

if ! timedatectl list-timezones | grep -Fxq "${TIMEZONE}"; then
  echo "ERROR: Invalid timezone '${TIMEZONE}'." >&2
  exit 1
fi

timedatectl set-timezone "${TIMEZONE}"
CURRENT_TIMEZONE="$(timedatectl show --property=Timezone --value)"

if [[ "${CURRENT_TIMEZONE}" != "${TIMEZONE}" ]]; then
  echo "ERROR: Failed to set timezone." >&2
  exit 1
fi

hostnamectl set-hostname "${NEW_HOSTNAME}"

if grep -Eq '^127\.0\.1\.1\s+' /etc/hosts; then
  sed -i "s/^127\.0\.1\.1\s\+.*/127.0.1.1 ${NEW_HOSTNAME}/" /etc/hosts
else
  echo "127.0.1.1 ${NEW_HOSTNAME}" >> /etc/hosts
fi

CURRENT_HOSTNAME="$(hostnamectl --static)"
if [[ "${CURRENT_HOSTNAME}" != "${NEW_HOSTNAME}" ]]; then
  echo "ERROR: Failed to set hostname." >&2
  exit 1
fi

echo "OK: Timezone set to ${TIMEZONE}."
echo "OK: Hostname set to ${NEW_HOSTNAME}."
