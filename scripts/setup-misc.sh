#!/bin/bash

echo "Creating group 'realtime'..."
(getent group realtime > /dev/null) || sudo groupadd realtime
echo "Adding user '$(whoami)' to group 'realtime'..."
sudo usermod -aG realtime "$(whoami)"

echo "Setting up dotfiles..."
cp -rv ${SCRIPT_DIR}/config/* $HOME/.config/

echo "Setting 'micro' as default text editor for Bash..."
echo 'export EDITOR="micro"' >> $HOME/.bashrc

echo 'fastfetch' >> $HOME/.bashrc

mkdir -p $HOME/.local/share/PrismLauncher
ln -s $HOME/.mnt/SAMSUNG@STORAGE/minecraft-instances $HOME/.local/share/PrismLauncher/instances

cp -rv ${SCRIPT_DIR}/bin $HOME/
cp -rv ${SCRIPT_DIR}/desktop $HOME/.local/share/applications

touch ${SCRIPT_FLAG}
