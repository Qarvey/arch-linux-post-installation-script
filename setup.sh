#!/bin/bash

set -euo pipefail

ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAGS="${SCRIPT_DIR}/flags"

mkdir -p ${FLAGS}

if [[ -e "${FLAGS}/part1.flag" ]]; then
    echo "Continuing setup..."
else
    chmod +x ${SCRIPT_DIR}/scripts/*.sh
fi

sudo -v

# PART 1

if [[ ! -e "${FLAGS}/part1.flag" ]]; then
    SCRIPTS=("setup-storage" "setup-btrfs-swap" "setup-metapac")

    for SCRIPT in "${SCRIPTS[@]}"; do
        SCRIPT_FLAG="${FLAGS}/part1-${SCRIPT}.flag"

        if [[ -e ${SCRIPT_FLAG} ]]; then
            echo "Script '${SCRIPT}.sh' already executed."
        else
            echo "Executing script '${SCRIPT}.sh'..."
            source ${SCRIPT_DIR}/scripts/${SCRIPT}.sh
        fi
    done
    
    touch "${FLAGS}/part1.flag"
    echo "${SCRIPT_DIR}/setup.sh" | sudo tee -a $HOME/.bash_profile
    reboot
fi

# PART 2

if [[ ! -e "${FLAGS}/part2.flag" ]]; then
    echo "Adding groups 'desktop' and 'hyprland' to 'metapac' configuration..."
    METAPAC_CONFIG="${SCRIPT_DIR}/part2-config.toml"
    sed -i "s/^PLACEHOLDER = \[/$(hostname) = [/" "${METAPAC_CONFIG}"
    cp -v ${METAPAC_CONFIG} $HOME/.config/metapac/config.toml
    echo "Attempting to install packages declared in the new 'metapac' groups..."
    metapac sync
    
    WD_1TB_MOUNTPOINT="$HOME/.mnt/WD-1TB"
    echo "Symlinking user directories in '${WD_1TB_MOUNTPOINT}' to home directory..."
    rm -rf $HOME/Documents
    ln -s $WD_1TB_MOUNTPOINT/@files/Documents $HOME/Documents
    rm -rf $HOME/Downloads
    ln -s $WD_1TB_MOUNTPOINT/@files/Downloads $HOME/Downloads
    rm -rf $HOME/Pictures
    ln -s $WD_1TB_MOUNTPOINT/@files/Pictures $HOME/Pictures
    rm -rf $HOME/Videos
    ln -s $WD_1TB_MOUNTPOINT/@files/Videos $HOME/Videos
    echo "Updating XDG user directories..."
    xdg-user-dirs-update
    
    echo "Attempting to create group 'realtime'..."
    (getent group realtime > /dev/null) || sudo groupadd realtime
    echo "Adding user '$(whoami)' to group 'realtime'..."
    sudo usermod -aG realtime "$(whoami)"
    
    echo "Enabling 'mpv' hardware acceleration..."
    mkdir -p $HOME/.config/mpv
    echo 'hwdec=auto' >> $HOME/.config/mpv/mpv.conf
    
    echo "Configuring Hyprland..."
    mkdir -p $HOME/.config/hypr
    cp -rv ${SCRIPT_DIR}/config/hypr/ $HOME/.config/hypr/
    
    echo "Loading the 'i2c-dev' module..."
    sudo modprobe i2c-dev
    echo "Attempting to create group 'i2c'..."
    (getent group i2c > /dev/null) || sudo groupadd i2c
    echo "Adding user '$(whoami)' to group 'i2c'..."
    sudo usermod -aG i2c $(whoami)
    
    echo "Setting 'micro' as default text editor for Fish..."
    echo 'set -gx EDITOR micro' >> $HOME/.config/fish/config.fish
    # echo 'set -gx VISUAL micro' >> $HOME/.config/fish/config.fish
    
    sed -i "\|^${SCRIPT_DIR}/setup.sh\$|d" "$HOME/.bash_profile"
    touch "${FLAGS}/part2.flag"

    echo "Setup complete!"
    for ((i=10; i>0; i--)); do
        echo -ne "\rRebooting in $i seconds... "
        sleep 1
    done
    reboot
else
    echo "Setup already complete."
fi
