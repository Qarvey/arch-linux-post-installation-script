#!/bin/bash
# Must be run as root

set -e

GRUB_CFG="/etc/default/grub"
BACKUP_CFG="/etc/default/grub.bak.$(date +%F_%T)"
cp "$GRUB_CFG" "$BACKUP_CFG"
echo "Backup created at $BACKUP_CFG\n"

CURRENT_LINE=$(grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_CFG")
CURRENT_PARAMS=$(echo "$CURRENT_LINE" | sed 's/^GRUB_CMDLINE_LINUX_DEFAULT="//' | sed 's/"$//')
if [[ "$CURRENT_PARAMS" != *"amdgpu.modeset=1"* ]]; then
    CURRENT_PARAMS="$CURRENT_PARAMS amdgpu.modeset=1"
fi
if [[ "$CURRENT_PARAMS" != *"amdgpu.dc=1"* ]]; then
    CURRENT_PARAMS="$CURRENT_PARAMS amdgpu.dc=1"
fi

sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$CURRENT_PARAMS\"|" "$GRUB_CFG"
echo "GRUB_CMDLINE_LINUX_DEFAULT updated to:"
grep '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_CFG"

if [ -d /sys/firmware/efi ]; then
    # UEFI system
    echo "Detected UEFI system"
    grub-mkconfig -o /boot/grub/grub.cfg
else
    # BIOS system
    echo "Detected BIOS system"
    grub-mkconfig -o /boot/grub/grub.cfg
fi
