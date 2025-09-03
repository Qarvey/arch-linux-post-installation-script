#!/bin/bash
set -euo pipefail
sudo -v
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating Btrfs subvolume '/@storage' in '$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')'..."
sudo btrfs subvolume create /@storage

SAMSUNG_STORAGE_UUID = $(lsblk -no UUID "$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')")
SAMSUNG_STORAGE_MOUNTPOINT = "$HOME/.mnt/SAMSUNG@STORAGE"
mkdir -p $SAMSUNG_STORAGE_MOUNTPOINT
if grep -q "UUID=${SAMSUNG_STORAGE_UUID}.*${SAMSUNG_STORAGE_MOUNTPOINT}" /etc/fstab; then
    echo "UUID ${SAMSUNG_STORAGE_UUID} is already configured to mount at '${SAMSUNG_STORAGE_MOUNTPOINT}' in `fstab`."
else
    echo "Configuring UUID ${SAMSUNG_STORAGE_UUID} to mount at '${SAMSUNG_STORAGE_MOUNTPOINT}' in `fstab`..."
    echo -e "\nUUID=${SAMSUNG_STORAGE_UUID}  ${SAMSUNG_STORAGE_MOUNTPOINT}  btrfs  subvol=/@storage,defaults,noatime,compress=zstd,commit=120  0 0" | sudo tee -a /etc/fstab
fi

WD_1TB_LABEL = "WD-1TB"
WD_1TB_MOUNTPOINT = "$HOME/.mnt/WD-1TB"
mkdir -p $WD_1TB_MOUNTPOINT
if grep -q "LABEL=${WD_1TB_LABEL}.*${WD_1TB_MOUNTPOINT}" /etc/fstab; then
    echo "LABEL ${WD_1TB_LABEL} is already configured to mount at '${WD_1TB_MOUNTPOINT}' in `fstab`."
else
    echo "Configuring LABEL ${WD_1TB_LABEL} to mount at '${WD_1TB_MOUNTPOINT}' in `fstab`..."
    echo "LABEL=${WD_1TB_LABEL}  ${WD_1TB_MOUNTPOINT}  btrfs  defaults,noatime,compress=zstd,commit=120  0 0" | sudo tee -a /etc/fstab
fi

echo "Updating system..."
sudo pacman -Syu --no-confirm

if pacman -Q paru &>/dev/null; then
    echo "`paru` found. Attempting to uninstall..."
    sudo -Rns --no-confirm paru
fi

echo "Attempting to install `yay`..."
cd $HOME
if ! pacman -Q yay &>/dev/null; then
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
else
    echo "`yay` is already installed."
fi

echo "Attempting to install `metapac`..."
if ! pacman -Q metapac &>/dev/null; then
    yay -S --noconfirm metapac
else
    echo "`metapac` is already installed."
fi

echo "Initializing `metapac` configuration..."
rm -rf $HOME/.config/metapac
mkdir -p $HOME/.config/metapac/groups
cp -v ${SCRIPT_DIR}/config.toml $HOME/.config/metapac/config.toml
cp -rv ${SCRIPT_DIR}/groups/. $HOME/.config/metapac/groups/
if [[ -e ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml ]]; then
    echo -e "File 'minimal-cachyos-base.toml' already exists.\nIt contains all the packages in your system and declares them for `metapac`."
else
    metapac unmanaged > ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml
fi
cp -v ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml $HOME/.config/metapac/groups/minimal-cachyos-base.toml

echo "Attempting to install packages declared in the `metapac` groups..."
metapac sync

###

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

chsh -s /usr/bin/fish
echo 'set -gx EDITOR micro' >> $HOME/.config/fish/config.fish
# echo 'set -gx VISUAL micro' >> $HOME/.config/fish/config.fish
