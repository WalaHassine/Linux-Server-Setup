# !/bin/bash 
KEY_PATH="$HOME/.ssh/id_ed25519"
if [ -f "$KEY_PATH" ]; then
    echo "[INFO] SSH key already exists at $KEY_PATH"
else
    echo "[INFO] Generating new SSH key at $KEY_PATH"
    ssh-keygen -t ed25519 -f "$KEY_PATH" -N "" -C "$(whoami)@$(hostname)"
    echo "[INFO] SSH key generated successfully"
fi

echo "[INFO] Your public key:"
    cat "${KEY_PATH}.pub"
