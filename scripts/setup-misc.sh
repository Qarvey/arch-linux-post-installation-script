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

touch ${SCRIPT_FLAG}
