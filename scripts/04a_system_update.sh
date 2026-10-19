#!/usr/bin/env bash
# =============================================================================
# 04a_system_update.sh
# Applies full package update/upgrade/autoremove and logs upgraded packages.
# Usage: sudo bash scripts/04a_system_update.sh
# =============================================================================

set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "ERROR: Run as root (sudo)." >&2
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="${REPO_ROOT}/logs"
LOG_FILE="${LOG_DIR}/upgrade_$(date +%F).log"

mkdir -p "${LOG_DIR}"

export DEBIAN_FRONTEND=noninteractive

echo "[$(date -Is)] apt-get update -y" | tee -a "${LOG_FILE}"
apt-get update -y 2>&1 | tee -a "${LOG_FILE}"

echo "[$(date -Is)] apt-get upgrade -y" | tee -a "${LOG_FILE}"
apt-get upgrade -y 2>&1 | tee -a "${LOG_FILE}"

echo "[$(date -Is)] apt-get autoremove -y" | tee -a "${LOG_FILE}"
apt-get autoremove -y 2>&1 | tee -a "${LOG_FILE}"

echo "OK: System update complete. Log: ${LOG_FILE}"
