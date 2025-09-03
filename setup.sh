#!/bin/bash

set -euo pipefail

sudo -v

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd $HOME

mkdir -p $HOME/.mnt/SAMSUNG@STORAGE
mkdir -p $HOME/.mnt/WD-1TB

echo -e "\nUUID=$(lsblk -no UUID "$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')")  /home/quijada/.mnt/SAMSUNG@STORAGE  btrfs  subvol=/@storage,defaults,noatime,compress=zstd,commit=120  0 0" | sudo tee -a /etc/fstab
echo "LABEL=WD-1TB  /home/quijada/.mnt/WD-1TB  btrfs  defaults,noatime,compress=zstd,commit=120  0 0" | sudo tee -a /etc/fstab

rm -rf $HOME/Documents
rm -rf $HOME/Downloads
rm -rf $HOME/Pictures
rm -rf $HOME/Videos

ln -s $HOME/.mnt/WD-1TB/@files/Documents $HOME/Documents
ln -s $HOME/.mnt/WD-1TB/@files/Downloads $HOME/Downloads
ln -s $HOME/.mnt/WD-1TB/@files/Pictures $HOME/Pictures
ln -s $HOME/.mnt/WD-1TB/@files/Videos $HOME/Videos

echo "Updating system..."
sudo pacman -Syu --no-confirm
echo "System updated."

if pacman -Q yay &>/dev/null; then
    echo "`paru` found. Attempting to uninstall..."
    sudo -Rns --no-confirm paru
    echo "`paru` uninstalled."
fi

echo "Attempting to install `yay`..."

if ! pacman -Q yay &>/dev/null; then
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
    echo "`yay` installed."
else
    echo "`yay` is already installed."
fi

echo "Attempting to install `metapac`..."

if ! pacman -Q metapac &>/dev/null; then
    yay -S --noconfirm metapac
    echo "`metapac` installed."
else
    echo "`metapac` is already installed."
fi

echo "Initializing `metapac` configuration..."

rm -rf $HOME/.config/metapac
mkdir -p $HOME/.config/metapac/groups
cp -v ${SCRIPT_DIR}/config.toml $HOME/.config/metapac/config.toml
cp -rv ${SCRIPT_DIR}/groups/. $HOME/.config/metapac/groups/

if [[ -e ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml ]]; then
    while true; do
        echo "File 'minimal-cachyos-base.toml' already exists. It contains all the packages in your system."
        read -t 10 -rp "Regenerate? (y/N) [default No in 10s]: " ANSWER
        case "$ANSWER" in
            [Yy]* ) metapac unmanaged > ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml; break;;
            [Nn]* | "" ) break;;
            * ) echo "Please answer with [y]es or [n]o."
        esac
    done
fi
cp -v ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml $HOME/.config/metapac/groups/minimal-cachyos-base.toml

echo "`metapac` configured. Attempting to install packages declared by `metapac`..."

metapac sync

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

chsh -s /usr/bin/fish
echo 'set -gx EDITOR micro' >> $HOME/.config/fish/config.fish
# echo 'set -gx VISUAL micro' >> $HOME/.config/fish/config.fish
