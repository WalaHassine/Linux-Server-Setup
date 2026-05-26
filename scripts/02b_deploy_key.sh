#!/usr/bin/env bash

#stric bash mode
set -eou pipefail

# validation de l'input  (nombre d'arguments et non nullité)
if [[ $# -lt 2 || -z "${1}" || -z "${2}"]]; then
    echo "Error : missing arguments"
    echo "Usage: $0 <username> <hostname>" >&2
    exit 1
fi

REMOTE_USER="$1"
REMOTE_HOST="$2"
PUB_KEY_PATH="$HOME/.ssh/id_ed25519.pub"
PATCH_FILE="/config/ssh_config_patch"
 
# Check if the public key file exists
if [[ ! -f "$PUB_KEY_PATH" ]]; then
    echo "Error: Public key file not found at $PUB_KEY_PATH" >&2
    echo "Run script/02a_gen_key.sh first ." >&2
    exit 1
fi

# check if the patch file exists
if [[ ! -f "$PATCH_FILE" ]]; then
    echo "Error: SSH config patch file not found at $PATCH_FILE" >&2
    exit 1
fi

echo "[1/4] Copying SSH public key to $REMOTE_USER@$REMOTE_HOST..."
ssh-copy-id -i "$HOME/.ssh/id_ed25519.pub" "$REMOTE_USER@$REMOTE_HOST"
echo "Public key deployed successfully."

echo "[2/4] Patching SSH config on $REMOTE_HOST..."
scp "$PATCH_FILE" "$REMOTE_USER@$REMOTE_HOST:/tmp/ssh_config_patch"

echo "[3/4] Applying SSH config patch and restarting SSH service on $REMOTE_HOST..."
ssh "${REMOTE_USER}@${REMOTE_HOST}" bash << 'REMOTE'
   set -euo pipefail
   SSHD_CONFIG="/etc/ssh/sshd_config"
   
   echo "Applying SSH config patch..."
   sudo patch -b "$SSHD_CONFIG" /tmp/ssh_config_patch"

   #validation config avant de redémarrer le service
    echo "Validating SSH config..."
    sudo sshd -t

    echo "Restarting SSH service..."
    sudo systemctl restart sshd
REMOTE

#verification de SSHD est active sur le remote host
echo "[4/4] Verifying SSH service status on $REMOTE_HOST..."
STATUS = $(ssh "$REMOTE_USER@REMOTE_HOST" "systemctl is-active sshd")
if [[ "$STATUS" == "active" ]]; then
    echo "SSH service is active on $REMOTE_HOST. Deployment successful."
else
    echo "Error: SSH service is not active on $REMOTE_HOST. Please check the configuration and logs." >&2
    exit 1
fi