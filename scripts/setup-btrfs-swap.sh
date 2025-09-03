#!/bin/bash

TEMP_MOUNTPOINT=$(mktemp -d /tmp/mnt.XXXXXX)
SWAP_SIZE=$(awk '/MemTotal:/ {print int(($2/1024/1024)+0.999)}' /proc/meminfo)

sudo mount -o subvolid=5 ${ROOT_DEVICE} ${TEMP_MOUNTPOINT}
if [ -d "${TEMP_MOUNTPOINT}/@swap" ]; then
  echo "Btrfs subvolume '/@swap' already exists in '${ROOT_DEVICE}'."
else
  echo "Creating Btrfs subvolume '/@swap' in '${ROOT_DEVICE}'..."
  sudo btrfs subvolume create ${TEMP_MOUNTPOINT}/@swap
fi

echo "Creating swap file..."
sudo btrfs filesystem mkswapfile --size ${SWAP_SIZE}g --uuid clear ${TEMP_MOUNTPOINT}/@swap/swapfile

sudo umount ${TEMP_MOUNTPOINT}

echo "Creating directory '/swap'..."
sudo mkdir -p /swap
echo "Mounting '${ROOT_DEVICE}/@swap' to '/swap'..."
sudo mount -o subvol=/@swap,noatime,compress=no ${ROOT_DEVICE} /swap
echo -e "\nUUID=$(lsblk -no UUID ${ROOT_DEVICE})  /swap  btrfs  subvol=/@swap,noatime,compress=no  0 0" | sudo tee -a /etc/fstab

echo "Activating '/swap/swapfile'..."
sudo swapon /swap/swapfile
echo "/swap/swapfile  none  swap  defaults,discard  0 0" | sudo tee -a /etc/fstab

touch "${FLAGS}/part1-setup-btrfs-swap.flag"
