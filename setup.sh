#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $HOME

rm -rf $HOME/Documents
rm -rf $HOME/Downloads
rm -rf $HOME/Pictures
rm -rf $HOME/Videos

mkdir -p $HOME/.mnt/SAMSUNG
mkdir -p $HOME/.mnt/WDC

# sudo echo "\nUUID=$(lsblk -no UUID "$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')")  /home/quijada/.mnt/SAMSUNG  btrfs  subvol=/@storage,defaults,noatime,compress=zstd,commit=120  0 0" >> /etc/fstab
# sudo echo "LABEL=WDC  /home/quijada/.mnt/WDC  btrfs  defaults,noatime,compress=zstd,commit=120  0 0" >> /etc/fstab

echo -e "\nUUID=$(lsblk -no UUID "$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')")  /home/quijada/.mnt/SAMSUNG  btrfs  subvol=/@storage,defaults,noatime,compress=zstd,commit=120  0 0" | sudo tee -a /etc/fstab
echo "LABEL=WDC  /home/quijada/.mnt/WDC  btrfs  defaults,noatime,compress=zstd,commit=120  0 0" | sudo tee -a /etc/fstab

ln -s $HOME/.mnt/WDC/@files/Documents $HOME/Documents
ln -s $HOME/.mnt/WDC/@files/Downloads $HOME/Downloads
ln -s $HOME/.mnt/WDC/@files/Pictures $HOME/Pictures
ln -s $HOME/.mnt/WDC/@files/Videos $HOME/Videos

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

yay -S metapac
mkdir -p $HOME/.config/metapac/groups
cp -v ${SCRIPT_DIR}/config.toml $HOME/.config/metapac/config.toml
cp -rv ${SCRIPT_DIR}/groups/. $HOME/.config/metapac/groups/
metapac unmanaged > $HOME/.config/metapac/groups/minimal-cachyos-base.toml
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

# sudo echo "[device]" >> /etc/NetworkManager/NetworkManager.conf
# sudo echo "wifi.backend=iwd" >> /etc/NetworkManager/NetworkManager.conf

echo -e "[device]\nwifi.backend=iwd" | sudo tee -a /etc/NetworkManager/NetworkManager.conf
sudo systemctl restart NetworkManager

yay -Rns wpa_supplicant

sudo modprobe i2c-dev
sudo usermod -aG i2c $USER

chsh -s /usr/bin/fish
echo 'set -gx EDITOR micro' >> $HOME/.config/fish/config.fish
echo 'set -gx VISUAL micro' >> $HOME/.config/fish/config.fish
