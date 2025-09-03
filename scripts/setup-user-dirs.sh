#!/bin/bash

WD_1TB_MOUNTPOINT = "$HOME/.mnt/WD-1TB"

echo "Symlinking user directories in '~/.mnt/$WD_1TB_LABEL/' to home directory..."
rm -rf $HOME/Documents
ln -s $WD_1TB_MOUNTPOINT/@files/Documents $HOME/Documents

rm -rf $HOME/Downloads
ln -s $WD_1TB_MOUNTPOINT/@files/Downloads $HOME/Downloads

rm -rf $HOME/Pictures
ln -s $WD_1TB_MOUNTPOINT/@files/Pictures $HOME/Pictures

rm -rf $HOME/Videos
ln -s $WD_1TB_MOUNTPOINT/@files/Videos $HOME/Videos

echo "Updating XDG user directories..."
xdg-user-dirs-update
