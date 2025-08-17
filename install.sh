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

