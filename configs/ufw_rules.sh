#!/usr/bin/env bash
# Example rules for future web services.
# Run manually when needed:
#   sudo ufw allow 80/tcp   # HTTP
#   sudo ufw allow 443/tcp  # HTTPS

set -euo pipefail

ufw allow 80/tcp
ufw allow 443/tcp
ufw status verbose
