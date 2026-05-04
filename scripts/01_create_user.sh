#!/usr/bin/env bash
# =============================================================================
# 01_create_user.sh
# Creates a non-root user with sudo privileges.
# Usage: sudo bash scripts/01_create_user.sh <USERNAME>
# =============================================================================

set -euo pipefail

# ------------------------------------------------------------
# 1. Validate input
# ------------------------------------------------------------
if [[ $# -lt 1 || -z "${1}" ]]; then
  echo "ERROR: No username supplied." >&2
  echo "Usage: sudo bash $0 <USERNAME>" >&2
  exit 1
fi

USERNAME="$1"

# ------------------------------------------------------------
# 2. Ensure script is run as root
# ------------------------------------------------------------
if [[ "$EUID" -ne 0 ]]; then
  echo "ERROR: This script must be run as root (use sudo)." >&2
  exit 1
fi

# ------------------------------------------------------------
# 3. Create the user
# ------------------------------------------------------------
if id "$USERNAME" &>/dev/null; then
  echo "INFO: User '$USERNAME' already exists. Skipping creation."
else
  useradd --create-home --shell /bin/bash "$USERNAME"
  echo "OK: User '$USERNAME' created."
fi

# ------------------------------------------------------------
# 4. Set the user's password (interactive prompt)
# ------------------------------------------------------------
echo "Set a password for '$USERNAME':"
passwd "$USERNAME"

# ------------------------------------------------------------
# 5. Add the user to the sudo group
# ------------------------------------------------------------
usermod --append --groups sudo "$USERNAME"
echo "OK: '$USERNAME' added to sudo group."

# ------------------------------------------------------------
# 6. Verify sudo group membership
# ------------------------------------------------------------
if id "$USERNAME" | grep -q "(sudo)"; then
  echo "OK: Verified — id output: $(id "$USERNAME")"
else
  echo "ERROR: '$USERNAME' was NOT found in the sudo group." >&2
  exit 1
fi

echo ""
echo "================================================================="
echo " Done. Log in as '$USERNAME' and run: sudo -l to confirm access."
echo "================================================================="
