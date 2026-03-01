#!/bin/bash
# install.sh - Installer for nvidia-flatpak-sync

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "================================================"
echo "       NVIDIA Flatpak Sync - Installer"
echo "================================================"
echo ""

# Check running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}ERROR: Please run as root (use sudo ./install.sh)${NC}"
    exit 1
fi

# Check flatpak is installed
if ! command -v flatpak &> /dev/null; then
    echo -e "${RED}ERROR: flatpak is not installed. Please install flatpak first.${NC}"
    exit 1
fi

# Check NVIDIA driver is present
if ! modinfo nvidia &> /dev/null; then
    echo -e "${RED}ERROR: NVIDIA kernel module not found. Are your NVIDIA drivers installed?${NC}"
    exit 1
fi

# Install libdnf5-plugin-actions if not already installed
if ! rpm -q libdnf5-plugin-actions &> /dev/null; then
    echo -e "${YELLOW}Installing libdnf5-plugin-actions dependency...${NC}"
    dnf install -y libdnf5-plugin-actions
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR: Failed to install libdnf5-plugin-actions${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ libdnf5-plugin-actions installed${NC}"
else
    echo -e "${GREEN}✓ libdnf5-plugin-actions already installed${NC}"
fi

# Check script files exist in current directory
if [ ! -f "./nvidia-flatpak-sync.sh" ]; then
    echo -e "${RED}ERROR: nvidia-flatpak-sync.sh not found in current directory.${NC}"
    echo "Make sure you are running this from inside the nvidia-flatpak-sync folder."
    exit 1
fi

if [ ! -f "./nvidia-flatpak-sync.service" ]; then
    echo -e "${RED}ERROR: nvidia-flatpak-sync.service not found in current directory.${NC}"
    echo "Make sure you are running this from inside the nvidia-flatpak-sync folder."
    exit 1
fi

if [ ! -f "./nvidia-flatpak-sync.actions" ]; then
    echo -e "${RED}ERROR: nvidia-flatpak-sync.actions not found in current directory.${NC}"
    echo "Make sure you are running this from inside the nvidia-flatpak-sync folder."
    exit 1
fi

echo -e "${YELLOW}Installing script to /usr/local/bin/...${NC}"
cp ./nvidia-flatpak-sync.sh /usr/local/bin/nvidia-flatpak-sync.sh
chmod +x /usr/local/bin/nvidia-flatpak-sync.sh
echo -e "${GREEN}✓ Script installed${NC}"

echo -e "${YELLOW}Installing systemd service...${NC}"
cp ./nvidia-flatpak-sync.service /etc/systemd/system/nvidia-flatpak-sync.service
echo -e "${GREEN}✓ Service installed${NC}"

echo -e "${YELLOW}Installing DNF actions hook...${NC}"
mkdir -p /etc/dnf/libdnf5-plugins/actions.d
cp ./nvidia-flatpak-sync.actions /etc/dnf/libdnf5-plugins/actions.d/nvidia-flatpak-sync.actions
echo -e "${GREEN}✓ DNF actions hook installed${NC}"

echo -e "${YELLOW}Enabling service to run on every boot...${NC}"
systemctl daemon-reload
systemctl enable nvidia-flatpak-sync.service
echo -e "${GREEN}✓ Service enabled${NC}"

echo -e "${YELLOW}Running sync now for the first time...${NC}"
echo ""
systemctl start nvidia-flatpak-sync.service
sleep 2

echo ""
echo "================================================"
echo -e "${GREEN}Installation complete!${NC}"
echo "================================================"
echo ""
echo "The service will now run automatically on every boot."
echo "You can check what it did at any time by running:"
echo ""
echo "  cat /var/log/nvidia-flatpak-sync.log"
echo ""
echo "Here is the log from the first run:"
echo "------------------------------------------------"
cat /var/log/nvidia-flatpak-sync.log
echo ""
