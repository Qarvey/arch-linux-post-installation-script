#!/bin/bash
# Refer to https://discuss.cachyos.org/t/tutorial-disable-or-remove-plymouth-boot-splash/10922

echo "Removing 'plymouth'..."
pacman -Q cachyos-plymouth-bootanimation &>/dev/null && sudo pacman -Rns --noconfirm cachyos-plymouth-bootanimation
pacman -Q plymouth &>/dev/null && sudo pacman -Rns --noconfirm plymouth 

MKINITCPIO_CONF="/etc/mkinitcpio.conf"
sudo cp ${MKINITCPIO_CONF} ${MKINITCPIO_CONF}.bak
sudo sed -i -E 's/\bplymouth\b//g; s/[[:space:]]{2,}/ /g; s/^[[:space:]]+|[[:space:]]+$//g' ${MKINITCPIO_CONF}
sudo mkinitcpio -P

LIMINE_CONF=$(sudo find /boot -type f -name "limine.conf")
sudo cp ${LIMINE_CONF} ${LIMINE_CONF}.bak
sudo sed -i -E 's/\bsplash\b//g; s/[[:space:]]{2,}/ /g; s/^[[:space:]]+|[[:space:]]+$//g' ${LIMINE_CONF}
sudo limine-update

DEFAULT_LIMINE_CONF="/etc/default/limine"
sudo cp ${DEFAULT_LIMINE_CONF} ${DEFAULT_LIMINE_CONF}.bak
sudo sed -i -E 's/\bsplash\b//g; s/[[:space:]]{2,}/ /g; s/^[[:space:]]+|[[:space:]]+$//g' ${DEFAULT_LIMINE_CONF}

touch "${FLAGS}/part1-${SCRIPT}.flag"
