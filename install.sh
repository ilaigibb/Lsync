#!/bin/bash
# lsync Installer
# Usage: curl -sL https://raw.githubusercontent.com/ilaigibb/Lsync/main/install.sh | bash

set -e

VERSION="1.0.0"
INSTALL_DIR="/usr/local/bin"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${CYAN}=== lsync v$VERSION Installer ===${NC}"
echo ""

echo "Downloading lsync..."
SCRIPT_TEMP="/tmp/lsync_install_$$"
curl -sL "https://raw.githubusercontent.com/ilaigibb/Lsync/main/lsync" -o "$SCRIPT_TEMP"
chmod +x "$SCRIPT_TEMP"

echo "Installing to $INSTALL_DIR..."

if [ ! -w "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Need sudo to install to $INSTALL_DIR${NC}"
    sudo cp "$SCRIPT_TEMP" "$INSTALL_DIR/lsync"
    sudo chmod +x "$INSTALL_DIR/lsync"
else
    cp "$SCRIPT_TEMP" "$INSTALL_DIR/lsync"
    chmod +x "$INSTALL_DIR/lsync"
fi

rm -f "$SCRIPT_TEMP"

echo -e "${GREEN}Installed lsync to $INSTALL_DIR/lsync${NC}"
echo ""

CONFIG_FILE="$HOME/.lsyncrc"
if [ -f "$CONFIG_FILE" ]; then
    echo -e "${YELLOW}Config already exists at $CONFIG_FILE${NC}"
    echo -n "Reconfigure? [y/N]: "
    read -r confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo ""
        echo -e "${GREEN}Installation complete!${NC}"
        exit 0
    fi
fi

echo ""
echo "Running initial setup..."
echo ""
"$INSTALL_DIR/lsync" init

echo ""
echo -e "${GREEN}Installation complete!${NC}"
