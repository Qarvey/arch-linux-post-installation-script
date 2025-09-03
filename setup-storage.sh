#!/bin/bash

set -euo pipefail

ROOT_DEVICE=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')

echo "Creating Btrfs subvolume '/@storage' in '${ROOT_DEVICE}'..."
sudo btrfs subvolume create /@storage

SAMSUNG_STORAGE_UUID = $(lsblk -no UUID ${ROOT_DEVICE})
SAMSUNG_STORAGE_MOUNTPOINT = "$HOME/.mnt/SAMSUNG@STORAGE"
echo "Creating mountpoint ${SAMSUNG_STORAGE_MOUNTPOINT}..."
mkdir -p ${SAMSUNG_STORAGE_MOUNTPOINT}
if grep -q "UUID=${SAMSUNG_STORAGE_UUID}.*${SAMSUNG_STORAGE_MOUNTPOINT}" /etc/fstab; then
    echo "UUID ${SAMSUNG_STORAGE_UUID} is already configured to mount at '${SAMSUNG_STORAGE_MOUNTPOINT}' in `fstab`."
else
    echo "Configuring UUID ${SAMSUNG_STORAGE_UUID} to mount at '${SAMSUNG_STORAGE_MOUNTPOINT}' in `fstab`..."
    echo -e "\nUUID=${SAMSUNG_STORAGE_UUID}  ${SAMSUNG_STORAGE_MOUNTPOINT}  btrfs  subvol=/@storage,defaults,noatime,compress=zstd,commit=120  0 0" | sudo tee -a /etc/fstab
fi

WD_1TB_LABEL = "WD-1TB"
WD_1TB_MOUNTPOINT = "$HOME/.mnt/WD-1TB"
echo "Creating mountpoint ${WD_1TB_MOUNTPOINT}..."
mkdir -p ${WD_1TB_MOUNTPOINT}
if grep -q "LABEL=${WD_1TB_LABEL}.*${WD_1TB_MOUNTPOINT}" /etc/fstab; then
    echo "LABEL ${WD_1TB_LABEL} is already configured to mount at '${WD_1TB_MOUNTPOINT}' in `fstab`."
else
    echo "Configuring LABEL ${WD_1TB_LABEL} to mount at '${WD_1TB_MOUNTPOINT}' in `fstab`..."
    echo "LABEL=${WD_1TB_LABEL}  ${WD_1TB_MOUNTPOINT}  btrfs  defaults,noatime,compress=zstd,commit=120  0 0" | sudo tee -a /etc/fstab
fi
