#!/bin/bash

set -euo pipefail

TEMP_MOUNTPOINT=$(mktemp -d /tmp/mnt.XXXXXX)
SWAP_SIZE=$(awk '/MemTotal:/ {print int(($2/1024/1024)+0.999)}' /proc/meminfo)

sudo mount -o subvolid=5 ${ROOT_DEVICE} ${TEMP_MOUNTPOINT}

sudo btrfs subvolume create ${TEMP_MOUNTPOINT}/@swap
sudo btrfs filesystem mkswapfile --size ${SWAP_SIZE}g --uuid clear ${TEMP_MOUNTPOINT}/@swap/swapfile

sudo umount ${TEMP_MOUNTPOINT}

sudo mkdir -p /swap
sudo mount -o subvol=/@swap,noatime,compress=no ${ROOT_DEVICE} /swap
echo -e "\nUUID=$(lsblk -no UUID ${ROOT_DEVICE})  /swap  btrfs  subvol=/@swap,noatime,compress=no  0 0" | sudo tee -a /etc/fstab

sudo swapon /swap/swapfile
echo "/swap/swapfile  none  swap  defaults,discard  0 0" | sudo tee -a /etc/fstab
