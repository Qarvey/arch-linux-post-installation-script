#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $HOME

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

${SCRIPT_DIR}/display-managers/lidm/lidm-service.sh

yay -S metapac
mkdir -p $HOME/.config/metapac/groups
cp ${SCRIPT_DIR}/config.toml $HOME/.config/metapac/config.toml
cp -rv ${SCRIPT_DIR}/groups/ $HOME/.config/metapac/groups/
metapac unmanaged > $HOME/.config/metapac/groups/all.toml
metapac sync

sudo systemctl stop wpa_supplicant
sudo systemctl disable wpa_supplicant
sudo systemctl mask wpa_supplicant

sudo echo "[device]" >> /etc/NetworkManager/NetworkManager.conf
sudo echo "wifi.backend=iwd" >> /etc/NetworkManager/NetworkManager.conf

sudo systemctl restart NetworkManager
