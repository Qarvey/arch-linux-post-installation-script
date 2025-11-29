#!/bin/bash

echo "Creating group 'realtime'..."
(getent group realtime > /dev/null) || sudo groupadd realtime
echo "Adding user '$(whoami)' to group 'realtime'..."
id -nG "$(whoami)" | grep -qw "realtime" || sudo usermod -aG realtime "$(whoami)"

echo "Setting up dotfiles..."
cp -rv ${SCRIPT_DIR}/config/* $HOME/.config/

if [[ -e "${FLAGS}/hyprland.flag" ]]; then
    if [[ -e "${FLAGS}/nwg.flag" ]]; then
        cp -rv $HOME/.config/hypr/hyprland-nwg.conf $HOME/.config/hypr/hyprland.conf
    elif [[ -e "${FLAGS}/noctalia.flag" ]]; then
        cp -rv $HOME/.config/hypr/hyprland-noctalia.conf $HOME/.config/hypr/hyprland.conf
    fi
fi

echo "Setting 'micro' and 'codium' as default text editors..."

if ! grep -Fxq 'export EDITOR="micro"' $HOME/.bashrc; then
    echo 'export EDITOR="micro"' >> $HOME/.bashrc
fi

if ! grep -Fxq 'export VISUAL="codium"' $HOME/.bashrc; then
    echo 'export VISUAL="codium"' >> $HOME/.bashrc
fi

if ! grep -Fxq "fastfetch" $HOME/.bashrc; then
    echo 'fastfetch' >> $HOME/.bashrc
fi

mkdir -p $HOME/.local/share/PrismLauncher
rm -rf $HOME/.local/share/PrismLauncher/instances
ln -s $HOME/.mnt/SAMSUNG@STORAGE/minecraft-instances $HOME/.local/share/PrismLauncher/instances

cp -rv ${SCRIPT_DIR}/bin $HOME/
sudo chmod -R +x $HOME/bin

cp -rv ${SCRIPT_DIR}/desktop $HOME/.local/share/applications

rm -rf $HOME/Desktop
ln -s $HOME/.local/share/applications $HOME/Desktop

sudo mkdir -p /etc/xdg/reflector
sudo cp -rv /etc/xdg/reflector/reflector.conf /etc/xdg/reflector/reflector.conf.bak
sudo cp -rv ${SCRIPT_DIR}/etc/xdg/reflector/reflector.conf /etc/xdg/reflector/reflector.conf

cp -r $HOME/.mnt/WD-1TB/\@files/.ssh $HOME/.ssh

touch ${SCRIPT_FLAG}
