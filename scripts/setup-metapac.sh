#!/bin/bash

echo "Setting up 'metapac'..."

echo "Updating system..."
sudo pacman -Syu --noconfirm

if pacman -Q paru &>/dev/null; then
    echo "'paru' found. Attempting to uninstall..."
    sudo -Rns --noconfirm paru
fi

echo "Attempting to install 'yay'..."
cd $HOME
if ! pacman -Q yay &>/dev/null; then
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si
    cd ..
    rm -rf yay
else
    echo "'yay' is already installed."
fi

echo "Attempting to install 'metapac'..."
if ! pacman -Q metapac &>/dev/null; then
    yay -S --noconfirm metapac
else
    echo "'metapac' is already installed."
fi

echo "Initializing 'metapac' configuration..."

METAPAC_CONFIG="${SCRIPT_DIR}/part1-config.toml"
sed -i "s/^PLACEHOLDER = \[/$(hostname) = [/" "${METAPAC_CONFIG}"

rm -rf $HOME/.config/metapac
mkdir -p $HOME/.config/metapac/groups
cp -v ${METAPAC_CONFIG} $HOME/.config/metapac/config.toml
cp -rv ${SCRIPT_DIR}/groups/. $HOME/.config/metapac/groups/
if [[ -e ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml ]]; then
    echo -e "File 'minimal-cachyos-base.toml' already exists.\nIt contains all the packages in your system and declares them for 'metapac'."
else
    metapac unmanaged > ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml
fi
cp -v ${SCRIPT_DIR}/groups/minimal-cachyos-base.toml $HOME/.config/metapac/groups/minimal-cachyos-base.toml

echo "Attempting to install packages declared in the 'metapac' groups..."
metapac sync

touch "${FLAGS}/part1-${SCRIPT}.flag"
