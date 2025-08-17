#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

sudo mkdir -p /etc/systemd/system/lidm.service
sudo cp ${SCRIPT_DIR}/systemd.service /etc/systemd/system/lidm.service
