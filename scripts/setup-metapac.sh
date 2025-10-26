#!/bin/bash

echo "Setting up 'metapac'..."

echo "Updating system..."
sudo pacman -Syu --noconfirm
sudo pacman -S inetutils --noconfirm

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

METAPAC_CONFIG="${SCRIPT_DIR}/config.toml"
sed -i "s/^PLACEHOLDER = \[/$(hostname) = [/" "${METAPAC_CONFIG}"

if [[ -e $HOME/.config/metapac ]]; then
    rm -rf $HOME/.config/metapac
fi
mkdir -p $HOME/.config/metapac

cp -v ${METAPAC_CONFIG} $HOME/.config/metapac/config.toml
cp -rv ${SCRIPT_DIR}/groups $HOME/.config/metapac/

if [[ -e ${SCRIPT_DIR}/groups/core.toml ]]; then
    echo -e "File 'core.toml' already exists.\nIt adds the core packages of your system to metapac's declaration."
else
    metapac unmanaged > ${SCRIPT_DIR}/groups/core.toml
fi

cp -rv ${SCRIPT_DIR}/groups/core.toml $HOME/.config/metapac/groups/

echo "Installing packages declared by 'metapac'"
metapac sync

touch ${SCRIPT_FLAG}
