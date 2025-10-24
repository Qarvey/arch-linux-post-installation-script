#!/bin/bash

set -euo pipefail

ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FLAGS="${SCRIPT_DIR}/flags"
mkdir -p ${FLAGS}

sudo -v

if [[ ! -e "${FLAGS}/setup-complete.flag" ]]; then
    SCRIPTS=("setup-storage" "setup-btrfs-swap" "setup-metapac")
    
    for SCRIPT in "${SCRIPTS[@]}"; do
        SCRIPT_FLAG="${FLAGS}/${SCRIPT}.flag"
    
        if [[ -e ${SCRIPT_FLAG} ]]; then
            echo "Script '${SCRIPT}.sh' already executed."
        else
            echo "Executing script '${SCRIPT}.sh'..."
            source ${SCRIPT_DIR}/scripts/${SCRIPT}.sh
        fi
    done
    
    echo "Creating group 'realtime'..."
    (getent group realtime > /dev/null) || sudo groupadd realtime
    echo "Adding user '$(whoami)' to group 'realtime'..."
    sudo usermod -aG realtime "$(whoami)"
    
    echo "Setting up dotfiles..."
    cp -rv ${SCRIPT_DIR}/config/* $HOME/.config/

    echo "Setting 'micro' as default text editor for Bash..."
    echo 'export EDITOR="micro"' >> $HOME/.bashrc
    
    touch "${FLAGS}/setup-complete.flag"
    echo "Setup complete!"
    
    for ((i=10; i>0; i--)); do
        echo -ne "\rRebooting in $i seconds... "
        sleep 1
    done
    
    reboot
else
    echo "Setup already complete."
fi
