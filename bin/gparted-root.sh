#!/bin/bash

# Allow root (local) to connect to your XWayland session
xhost +SI:localuser:root

# Run GParted via pkexec
pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" gparted

# Optionally, revoke access after you close GParted
xhost -SI:localuser:root
