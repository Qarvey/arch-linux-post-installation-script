#!/bin/bash
# Script to ensure 'discard' option is present in swap entries in /etc/fstab

set -euo pipefail

FSTAB="/etc/fstab"
BACKUP="/etc/fstab.bak.$(date +%F-%H%M%S)"

# Make a backup
cp "$FSTAB" "$BACKUP"
echo "Backup created at $BACKUP"

# Process fstab safely
awk '
$3 == "swap" {
    opts = $4
    # If "discard" already present, leave unchanged
    if (opts ~ /(^|,)discard(,|$)/) {
        print
    } else {
        # Append discard
        $4 = opts ",discard"
        print
    }
    next
}
{ print }
' "$BACKUP" > "$FSTAB"

echo "Updated $FSTAB. Please verify before rebooting."
