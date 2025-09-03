#!/bin/bash

set -euo pipefail

ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PART1_FLAG="${SCRIPT_DIR}/flags/part1.flag"

if [[ -e ${PART1_FLAG} ]]; then
    echo "Continuing setup..."
else
    chmod +x ${SCRIPT_DIR}/scripts/*.sh
fi

sudo -v

# PART 1

if [[ ! -e ${PART1_FLAG} ]]; then
    source ${SCRIPT_DIR}/scripts/remove-plymouth.sh
    source ${SCRIPT_DIR}/scripts/setup-storage.sh
    source ${SCRIPT_DIR}/scripts/setup-btrfs-swap.sh
    source ${SCRIPT_DIR}/scripts/setup-metapac.sh
    
    touch ${PART1_FLAG}
    echo "${SCRIPT_DIR}/setup.sh" | sudo tee -a $HOME/.bash_profile
    reboot
fi

# PART 2

PART2_FLAG="${SCRIPT_DIR}/flags/part2.flag"

if [[ ! -e ${PART2_FLAG} ]]; then
    source ${SCRIPT_DIR}/scripts/declare-hyprland-desktop.sh
    source ${SCRIPT_DIR}/scripts/setup-user-dirs.sh
    
    echo "Attempting to create group 'realtime'..."
    (getent group realtime > /dev/null) || sudo groupadd realtime
    echo "Adding user '$(whoami)' to group 'realtime'..."
    sudo usermod -aG realtime "$(whoami)"
    
    echo "Enabling 'mpv' hardware acceleration..."
    mkdir -p $HOME/.config/mpv
    echo 'hwdec=auto' >> $HOME/.config/mpv/mpv.conf
    
    echo "Configuring Hyprland..."
    mkdir -p $HOME/.config/hypr
    cp -rv ${SCRIPT_DIR}/hypr/ $HOME/.config/hypr/
    
    echo "Disabling 'wpa_supplicant'..."
    sudo systemctl stop wpa_supplicant
    sudo systemctl disable wpa_supplicant
    sudo systemctl mask wpa_supplicant
    
    echo "Replacing 'wpa_supplicant' with 'iwd' as WiFi backend..."
    echo -e "[device]\nwifi.backend=iwd" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
    sudo systemctl restart NetworkManager
    
    echo "Uninstalling 'wpa_supplicant'..."
    yay -Rns --noconfirm wpa_supplicant
    
    echo "Loading the 'i2c-dev' module..."
    sudo modprobe i2c-dev
    echo "Adding user '$(whoami)' to group 'i2c'..."
    sudo usermod -aG i2c $(whoami)
    
    echo "Setting 'micro' as default text editor for Fish..."
    echo 'set -gx EDITOR micro' >> $HOME/.config/fish/config.fish
    # echo 'set -gx VISUAL micro' >> $HOME/.config/fish/config.fish
    
    sed -i "\|^${SCRIPT_DIR}/setup.sh\$|d" "$HOME/.bash_profile"
    touch ${PART2_FLAG}

    echo "Setup complete!"
    for ((i=10; i>0; i--)); do
        echo -ne "\rRebooting in $i seconds... "
        sleep 1
    done
    reboot
else
    echo "Setup already complete."
fi
