#!/bin/bash

set -euo pipefail

ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FLAGS="${SCRIPT_DIR}/flags"
mkdir -p ${FLAGS}

sudo -v

if [[ ! -e "${FLAGS}/setup-complete.flag" ]]; then
    SCRIPTS=("setup-storage" "setup-btrfs-swap" "setup-metapac" "setup-limine-extras" "setup-misc")
    
    for SCRIPT in "${SCRIPTS[@]}"; do
        SCRIPT_FLAG="${FLAGS}/${SCRIPT}.flag"
    
        if [[ -e ${SCRIPT_FLAG} ]]; then
            echo "Script '${SCRIPT}.sh' already executed."
        else
            echo "Executing script '${SCRIPT}.sh'..."
            source ${SCRIPT_DIR}/scripts/${SCRIPT}.sh

            while true; do
                if ! read -t 10 -p "Continue? [Y/n] (auto-continues in 10s) " answer; then
                    echo "Timed out — continuing by default."
                fi
            
                # Default to Y if empty
                answer=${answer:-Y}
                answer=$(echo "$answer" | xargs)
            
                # Validate input
                if [[ "$answer" =~ ^[YyNn]$ ]]; then
                    break  # valid input, exit loop
                else
                    echo "Invalid input. Please enter Y or N."
                fi
            done
            
            # Act on valid input
            if [[ "$answer" =~ ^[Nn]$ ]]; then
                echo "Exiting script."
                exit 1
            else
                echo "Continuing..."
            fi
        fi
    done
    
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
