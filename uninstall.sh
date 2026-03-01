#!/bin/bash
# uninstall.sh - Uninstaller for nvidia-flatpak-sync

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "================================================"
echo "       NVIDIA Flatpak Sync - Uninstaller"
echo "================================================"
echo ""

# Check running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: Please run as root (use sudo ./uninstall.sh)${NC}"
    exit 1
fi

echo -e "${YELLOW}Stopping and disabling service...${NC}"
systemctl stop nvidia-flatpak-sync.service 2>/dev/null
systemctl disable nvidia-flatpak-sync.service 2>/dev/null
echo -e "${GREEN}✓ Service stopped and disabled${NC}"

echo -e "${YELLOW}Removing DNF actions hook...${NC}"
rm -f /etc/dnf/libdnf5-plugins/actions.d/nvidia-flatpak-sync.actions
echo -e "${GREEN}✓ DNF actions hook removed${NC}"

echo -e "${YELLOW}Removing service file...${NC}"
rm -f /etc/systemd/system/nvidia-flatpak-sync.service
systemctl daemon-reload
echo -e "${GREEN}✓ Service file removed${NC}"

echo -e "${YELLOW}Removing script...${NC}"
rm -f /usr/local/bin/nvidia-flatpak-sync.sh
echo -e "${GREEN}✓ Script removed${NC}"

echo -e "${YELLOW}Removing log file...${NC}"
rm -f /var/log/nvidia-flatpak-sync.log
echo -e "${GREEN}✓ Log file removed${NC}"

echo ""
echo "================================================"
echo -e "${GREEN}Uninstall complete!${NC}"
echo "================================================"
echo ""
