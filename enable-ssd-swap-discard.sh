#!/bin/bash
# Script to add 'discard' option to swap entries on SSDs in /etc/fstab

set -euo pipefail

FSTAB="/etc/fstab"
BACKUP="/etc/fstab.bak.$(date +%F-%H%M%S)"

# Make a backup
cp "$FSTAB" "$BACKUP"
echo "Backup created at $BACKUP"

# Function: resolve device name from fstab spec (UUID=, LABEL=, /dev/…)
resolve_dev() {
    local spec="$1"
    if [[ "$spec" =~ ^UUID= ]]; then
        blkid -U "${spec#UUID=}" || return 1
    elif [[ "$spec" =~ ^LABEL= ]]; then
        blkid -L "${spec#LABEL=}" || return 1
    else
        echo "$spec"
    fi
}

# Function: check if device is SSD
is_ssd() {
    local dev="$1"
    dev="${dev#/dev/}"

    # If it's a partition, strip the number (sda1 → sda, nvme0n1p2 → nvme0n1)
    local base="${dev%%[0-9]*}"
    base="${base%%p*}"

    if [[ -r "/sys/block/$base/queue/rotational" ]]; then
        [[ $(< "/sys/block/$base/queue/rotational") -eq 0 ]]
    else
        return 1
    fi
}

# Process fstab
> "$FSTAB"
while read -r line; do
    # Skip comments and blank lines
    [[ -z "$line" || "$line" =~ ^# ]] && { echo "$line" >> "$FSTAB"; continue; }

    set -- $line
    devspec=$1
    mnt=$2
    fstype=$3
    opts=$4

    if [[ "$fstype" == "swap" ]]; then
        realdev=$(resolve_dev "$devspec" 2>/dev/null || echo "")
        if [[ -n "$realdev" && $(is_ssd "$realdev" && echo ssd || echo hdd) == "ssd" ]]; then
            echo "Swap on $realdev → SSD detected"
            if [[ "$opts" =~ (^|,)discard(,|$) ]]; then
                echo "  Already has discard → unchanged"
                echo "$line" >> "$FSTAB"
            else
                echo "  Adding discard option"
                echo "$devspec $mnt $fstype ${opts},discard ${5:-0} ${6:-0}" >> "$FSTAB"
            fi
        else
            echo "Swap on ${realdev:-$devspec} → HDD or unknown → unchanged"
            echo "$line" >> "$FSTAB"
        fi
    else
        echo "$line" >> "$FSTAB"
    fi
done < "$BACKUP"

echo "Done. Updated $FSTAB (discard only for swap on SSDs)."
