#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $HOME

mkdir -p $HOME/.mnt/samsung
mkdir -p $HOME/.mnt/btrfs_hdd
mkdir -p $HOME/Documents
mkdir -p $HOME/Downloads
mkdir -p $HOME/Pictures
mkdir -p $HOME/Videos

sudo echo "LABEL=storage  /home/quijada/.mnt/samsung  btrfs  defaults,noatime,compress=zstd  0 0" >> /etc/fstab
sudo echo "LABEL=btrfs_hdd  /home/quijada/.mnt/btrfs_hdd  btrfs  defaults,noatime,compress=zstd  0 0" >> /etc/fstab

ln -s $HOME/.mnt/btrfs_hdd/@files/Documents $HOME/Documents
ln -s $HOME/.mnt/btrfs_hdd/@files/Downloads $HOME/Downloads
ln -s $HOME/.mnt/btrfs_hdd/@files/Pictures $HOME/Pictures
ln -s $HOME/.mnt/btrfs_hdd/@files/Videos $HOME/Videos

sudo pacman -S --needed git base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay

${SCRIPT_DIR}/display-managers/lidm/lidm-service.sh

yay -S metapac
mkdir -p $HOME/.config/metapac/groups
cp -v ${SCRIPT_DIR}/config.toml $HOME/.config/metapac/config.toml
cp -rv ${SCRIPT_DIR}/groups/ $HOME/.config/metapac/groups/
metapac unmanaged > $HOME/.config/metapac/groups/all.toml
metapac sync

xdg-user-dirs-update

echo 'EDITOR=micro' >> $HOME/.bashrc
read -r -d '' FISH_SNIPPET <<'EOF'
if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} == 1 ]]
then
    shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
    exec fish $LOGIN_OPTION
fi
EOF
echo -e '$FISH_SNIPPET' >> $HOME/.bashrc
source $HOME/.bashrc

USER=$(whoami)
if ! getent group realtime > /dev/null; then
    sudo groupadd realtime
fi
sudo usermod -aG realtime "$USER"

mkdir -p $HOME/.config/mpv
echo 'hwdec=auto' >> $HOME/.config/mpv/mpv.conf

mkdir -p $HOME/.config/hypr
cp -rv ${SCRIPT_DIR}/hypr/ $HOME/.config/hypr/

# sudo systemctl stop wpa_supplicant
# sudo systemctl disable wpa_supplicant
# sudo systemctl mask wpa_supplicant

# sudo echo "[device]" >> /etc/NetworkManager/NetworkManager.conf
# sudo echo "wifi.backend=iwd" >> /etc/NetworkManager/NetworkManager.conf

# sudo systemctl restart NetworkManager
