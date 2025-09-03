#!/bin/bash

set -euo pipefail

ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PART1_FLAG="${SCRIPT_DIR}/flags/part1.flag"

[[ -e ${PART1_FLAG} ]] && echo "Continuing setup..."

sudo -v

chmod +x ${SCRIPT_DIR}/scripts/*.sh

# PART 1

if [[ ! -e ${PART1_FLAG} ]]; then
    source ${SCRIPT_DIR}/scripts/setup-storage.sh
    source ${SCRIPT_DIR}/scripts/setup-btrfs-swap.sh
    source ${SCRIPT_DIR}/scripts/setup-metapac.sh
    touch ${PART1_FLAG}

    echo "${SCRIPT_DIR}/setup.sh" | sudo tee -a ~/.bash_profile
    
    reboot
fi

# PART 2

echo "Adding groups 'desktop' and 'hyprland' to `metapac` declaration..."
METAPAC_CONFIG="${SCRIPT_DIR}/config.toml"
NEW_METAPAC_GROUPS=("desktop" "hyprland")
for val in "${NEW_METAPAC_GROUPS[@]}"; do
    sed -i "/^\[hostname_groups\]/,/^\[/{ 
        /^$(hostname) = \[/,/]/{
            /]/i \  \"${val}\",
        }
    }" "${METAPAC_CONFIG}"
done
cp -v ${METAPAC_CONFIG} $HOME/.config/metapac/config.toml

echo "Attempting to install packages declared in the new `metapac` groups..."
metapac sync

echo "Symlinking user directories in '~/.mnt/$WD_1TB_LABEL/' to home directory..."
rm -rf $HOME/Documents
ln -s $WD_1TB_MOUNTPOINT/@files/Documents $HOME/Documents

rm -rf $HOME/Downloads
ln -s $WD_1TB_MOUNTPOINT/@files/Downloads $HOME/Downloads

rm -rf $HOME/Pictures
ln -s $WD_1TB_MOUNTPOINT/@files/Pictures $HOME/Pictures

rm -rf $HOME/Videos
ln -s $WD_1TB_MOUNTPOINT/@files/Videos $HOME/Videos

xdg-user-dirs-update

USER=$(whoami)
if ! getent group realtime > /dev/null; then
    sudo groupadd realtime
fi
sudo usermod -aG realtime "$USER"

mkdir -p $HOME/.config/mpv
echo 'hwdec=auto' >> $HOME/.config/mpv/mpv.conf

mkdir -p $HOME/.config/hypr
cp -rv ${SCRIPT_DIR}/hypr/ $HOME/.config/hypr/

sudo systemctl stop wpa_supplicant
sudo systemctl disable wpa_supplicant
sudo systemctl mask wpa_supplicant

echo -e "[device]\nwifi.backend=iwd" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
sudo systemctl restart NetworkManager

yay -Rns --noconfirm wpa_supplicant

sudo modprobe i2c-dev
sudo usermod -aG i2c $USER

echo 'set -gx EDITOR micro' >> $HOME/.config/fish/config.fish
# echo 'set -gx VISUAL micro' >> $HOME/.config/fish/config.fish
