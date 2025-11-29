#!/bin/bash

echo "Setting up 'metapac'..."

echo "Updating system..."
sudo pacman -Syu --noconfirm

echo "Attempting to install 'paru'..."
cd $HOME
if ! pacman -Q paru &>/dev/null; then
    sudo pacman -S --noconfirm --needed git base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
else
    echo "'paru' is already installed."
fi

echo "Attempting to install 'metapac'..."
if ! pacman -Q metapac &>/dev/null; then
    paru -S --noconfirm metapac
else
    echo "'metapac' is already installed."
fi

echo "Initializing 'metapac' configuration..."

METAPAC_CONFIG="${SCRIPT_DIR}/config.toml"

if [[ -e $HOME/.config/metapac ]]; then
    rm -rf $HOME/.config/metapac
fi
mkdir -p $HOME/.config/metapac

cp -v ${METAPAC_CONFIG} $HOME/.config/metapac/config.toml
cp -rv ${SCRIPT_DIR}/groups $HOME/.config/metapac/
cp -rv ${SCRIPT_DIR}/determinant-groups $HOME/.config/metapac/unused-groups

if [[ -e ${SCRIPT_DIR}/groups/core.toml ]]; then
    echo -e "File 'core.toml' already exists.\nIt adds the core packages of your system to metapac's declaration."
else
    metapac unmanaged > ${SCRIPT_DIR}/groups/core.toml
fi

cp -rv ${SCRIPT_DIR}/groups/core.toml $HOME/.config/metapac/groups/

if [[ -e "${FLAGS}/hyprland.flag" || -e "${FLAGS}/niri.flag" ]]; then
    while true; do
        echo "Select a Wayland compositor:\n1) hyprland (default)\n2) niri"
        read -r -t 10 -p "Enter choice [1-2] (defaults in 10s): " choice

        if [[ -z "${choice}" ]]; then
            choice=1
        fi

        case "${choice}" in
            1)
                mv $HOME/.config/metapac/unused-groups/hyprland.toml $HOME/.config/metapac/groups/hyprland.toml
                touch "${FLAGS}/hyprland.flag"
                break
                ;;
            2)
                mv $HOME/.config/metapac/unused-groups/niri.toml $HOME/.config/metapac/groups/niri.toml
                touch "${FLAGS}/niri.flag"
                break
                ;;
            *)
                echo "Invalid choice."
                ;;
        esac
    done
else
    echo "Wayland compositor already selected."
    if [[ -e "${FLAGS}/hyprland.flag" ]]; then
        mv $HOME/.config/metapac/unused-groups/hyprland.toml $HOME/.config/metapac/groups/hyprland.toml
    elif [[ -e "${FLAGS}/niri.flag" ]]; then
        mv $HOME/.config/metapac/unused-groups/niri.toml $HOME/.config/metapac/groups/niri.toml
    fi
fi

if [[ -e "${FLAGS}/nwg.flag" || -e "${FLAGS}/noctalia.flag" ]]; then
    if [[ -e "${FLAGS}/hyprland.flag" ]]; then
        while true; do
            echo "Select a desktop shell:\n1) nwg-panel and rofi (default)\n2) noctalia-shell"
            read -r -t 10 -p "Enter choice [1-2] (defaults in 10s): " choice

            if [[ -z "${choice}" ]]; then
                choice=1
            fi

            case "${choice}" in
                1)
                    mv $HOME/.config/metapac/unused-groups/nwg.toml $HOME/.config/metapac/groups/nwg.toml
                    touch "${FLAGS}/nwg.flag"
                    break
                    ;;
                2)
                    mv $HOME/.config/metapac/unused-groups/noctalia.toml $HOME/.config/metapac/groups/noctalia.toml
                    touch "${FLAGS}/noctalia.flag"
                    break
                    ;;
                *)
                    echo "Invalid choice."
                    ;;
            esac
        done
    elif [[ -e "${FLAGS}/niri.flag" ]]; then
        mv $HOME/.config/metapac/unused-groups/noctalia.toml $HOME/.config/metapac/groups/noctalia.toml
        touch "${FLAGS}/noctalia.flag"
    fi
else
    echo "Desktop shell already selected."
    if [[ -e "${FLAGS}/noctalia.flag" ]]; then
        mv $HOME/.config/metapac/unused-groups/noctalia.toml $HOME/.config/metapac/groups/noctalia.toml
    elif [[ -e "${FLAGS}/nwg.flag" ]]; then
        mv $HOME/.config/metapac/unused-groups/nwg.toml $HOME/.config/metapac/groups/nwg.toml
    fi
fi

echo "Installing packages declared by 'metapac'"
metapac sync
metapac clean

touch ${SCRIPT_FLAG}
