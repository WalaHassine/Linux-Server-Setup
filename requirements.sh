#!/usr/bin/env bash
# =============================================================================
# requirements.sh
# Installs required packages while pinning currently installed versions when
# available from dpkg metadata.
# Usage: sudo bash requirements.sh
# =============================================================================

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update -y

pin_or_install() {
  local pkg="$1"
  if dpkg-query -W -f='${Status}' "${pkg}" 2>/dev/null | grep -q "install ok installed"; then
    local version
    version="$(dpkg-query -W -f='${Version}' "${pkg}")"
    echo "Installing pinned ${pkg}=${version}"
    apt-get install -y "${pkg}=${version}"
  else
    echo "Installing latest ${pkg} (not currently installed)."
    apt-get install -y "${pkg}"
  fi
}

PACKAGES=(
  git
  curl
  jq
  openssl
  docker.io
  shellcheck
  make
  patch
  ufw
  unattended-upgrades
  fail2ban
)

for pkg in "${PACKAGES[@]}"; do
  pin_or_install "${pkg}"
done

echo "OK: requirements installation completed."
