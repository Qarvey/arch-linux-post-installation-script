#!/bin/bash

echo "Setting up extra Limine configurations..."

LIMINE_CONF="/etc/default/limine"
APPARMOR_FLAG="lsm=landlock,lockdown,yama,integrity,apparmor,bpf"

sudo cp -rv /etc/limine-entry-tool.conf ${LIMINE_CONF}

if grep -qF "${APPARMOR_FLAG}" "${LIMINE_CONF}"; then
  echo "Flag is already present in ${LIMINE_CONF}."
else
  sudo sed -i -E "s/^(KERNEL_CMDLINE\[default\]\+=\"[^\"]*)\"/\1 ${APPARMOR_FLAG}\"/" "${LIMINE_CONF}"
  echo "Appended AppArmor LSM flag to ${LIMINE_CONF}."
fi

MKINITCPIO_CONF="/etc/mkinitcpio.conf"
HOOK="btrfs-overlayfs"

if [ -f "${MKINITCPIO_CONF}" ]; then
  if grep -q -E '^[[:space:]]*HOOKS=\(' "${MKINITCPIO_CONF}"; then
    current_hooks=$(grep -E '^[[:space:]]*HOOKS=\(' "${MKINITCPIO_CONF}" | head -n1)

    sudo cp -rv ${MKINITCPIO_CONF} ${MKINITCPIO_CONF}.bak

    if grep -q "${HOOK}" <<< "${current_hooks}"; then
      echo "${HOOK} is already in HOOKS."
    else
      sudo sed -i -E "/^[[:space:]]*HOOKS=\(/ s/\bfilesystems\b/& ${HOOK}/" "${MKINITCPIO_CONF}"
      echo "Inserted ${MKINITCPIO_CONF} after 'filesystems' in HOOKS."
    fi
  else
    echo "Error: Couldn't find HOOKS= line in ${MKINITCPIO_CONF}"
  fi
else
  echo "Error: ${MKINITCPIO_CONF} not found."
fi

sudo limine-update
sudo limine-scan
sudo systemctl enable --now linine-snapper-sync.service
sudo systemctl enable --now apparmor.service

touch ${SCRIPT_FLAG}
