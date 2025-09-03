#!/bin/bash

echo "Adding groups 'desktop' and 'hyprland' to 'metapac' declaration..."
METAPAC_CONFIG="${SCRIPT_DIR}/part2-config.toml"
sed -i "s/^PLACEHOLDER = \[/$(hostname) = [/" "${METAPAC_CONFIG}"
cp -v ${METAPAC_CONFIG} $HOME/.config/metapac/config.toml

echo "Attempting to install packages declared in the new 'metapac' groups..."
metapac sync
