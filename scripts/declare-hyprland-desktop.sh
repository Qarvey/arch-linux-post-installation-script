#!/bin/bash

echo "Adding groups 'desktop' and 'hyprland' to 'metapac' declaration..."
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

echo "Attempting to install packages declared in the new 'metapac' groups..."
metapac sync
