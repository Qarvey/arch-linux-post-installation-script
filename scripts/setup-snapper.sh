#!/bin/bash

echo "Setting up Snapper..."

SAMSUNG_STORAGE_UUID=$(lsblk -no UUID ${ROOT_DEVICE})
TEMP_MOUNTPOINT=$(mktemp -d /tmp/mnt.XXXXXX)
sudo mount -o subvolid=5 ${ROOT_DEVICE} ${TEMP_MOUNTPOINT}

if [ -d "${TEMP_MOUNTPOINT}/@root_snapshots" ]; then
  echo "Btrfs subvolume '/@root_snapshots' already exists in '${ROOT_DEVICE}'."
else
  echo "Creating Btrfs subvolume '/@root_snapshots' in '${ROOT_DEVICE}'..."
  sudo btrfs subvolume create ${TEMP_MOUNTPOINT}/@root_snapshots
fi

# if [ -d "${TEMP_MOUNTPOINT}/@home_snapshots" ]; then
#   echo "Btrfs subvolume '/@home_snapshots' already exists in '${ROOT_DEVICE}'."
# else
#   echo "Creating Btrfs subvolume '/@home_snapshots' in '${ROOT_DEVICE}'..."
#   sudo btrfs subvolume create ${TEMP_MOUNTPOINT}/@home_snapshots
# fi

sudo umount ${TEMP_MOUNTPOINT}
rmdir ${TEMP_MOUNTPOINT}

echo "Creating Snapper configuration(s)..."
if [ -f /etc/snapper/configs/root ]; then
    echo "Snapper config 'root' already exists. Skipping creation."
else
    echo "Creating Snapper config 'root'..."
    sudo snapper -c root create-config /
fi
# sudo snapper -c home create-config /home

if grep -q "UUID=${SAMSUNG_STORAGE_UUID}.*/.snapshots" /etc/fstab; then
    echo "SUBVOLUME '@root_snapshots' in UUID ${SAMSUNG_STORAGE_UUID} is already configured to mount at '/.snapshots' in 'fstab'."
else
    echo "Configuring SUBVOLUME '@root_snapshots' in UUID ${SAMSUNG_STORAGE_UUID} to mount at '/.snapshots' in 'fstab'..."
    echo -e "\nUUID=${SAMSUNG_STORAGE_UUID}  /.snapshots  btrfs  subvol=/@root_snapshots,defaults,noatime,compress=zstd  0 0" | sudo tee -a /etc/fstab

    echo "Temporarily mounting SUBVOLUME '@root_snapshots' in UUID ${SAMSUNG_STORAGE_UUID} to '/.snapshots'..."
    sudo mount -o subvol=@root_snapshots ${SAMSUNG_STORAGE_UUID} /.snapshots
fi

touch ${SCRIPT_FLAG}
