#!/bin/bash
# nvidia-flatpak-sync.sh
# Automatically syncs flatpak NVIDIA runtime to match system NVIDIA driver version.
# Runs on boot via systemd. Logs to /var/log/nvidia-flatpak-sync.log

LOG="/var/log/nvidia-flatpak-sync.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

log "=== NVIDIA Flatpak Sync Started ==="

# Get system NVIDIA driver version (e.g. 580.126.18)
SYS_VERSION=$(modinfo nvidia 2>/dev/null | grep "^version:" | awk '{print $2}')

if [ -z "$SYS_VERSION" ]; then
    log "ERROR: Could not detect system NVIDIA driver version. Is the nvidia module loaded?"
    log "=== Sync Aborted ==="
    exit 1
fi

log "System NVIDIA driver version: $SYS_VERSION"

# Convert version to flatpak format (dots to dashes, e.g. 580.126.18 -> 580-126-18)
FLATPAK_VERSION=$(echo "$SYS_VERSION" | tr '.' '-')
GL_ID="org.freedesktop.Platform.GL.nvidia-${FLATPAK_VERSION}"
GL32_ID="org.freedesktop.Platform.GL32.nvidia-${FLATPAK_VERSION}"

log "Expected flatpak runtime: $GL_ID"

# --- STEP 1: Install correct runtimes if missing ---
GL_INSTALLED=$(flatpak list --system | grep -c "^nvidia-${FLATPAK_VERSION}[[:space:]]")
GL32_INSTALLED=$(flatpak list --system | grep -c "org\.freedesktop\.Platform\.GL32\.nvidia-${FLATPAK_VERSION}")

if [ "$GL_INSTALLED" -ge 1 ] && [ "$GL32_INSTALLED" -ge 1 ]; then
    log "Correct NVIDIA flatpak runtimes already installed (${FLATPAK_VERSION})."
else
    log "Correct runtimes missing — installing now..."

    if [ "$GL_INSTALLED" -lt 1 ]; then
        log "Installing $GL_ID..."
        flatpak install -y --system flathub "$GL_ID" >> "$LOG" 2>&1
        if [ $? -eq 0 ]; then
            log "Successfully installed $GL_ID"
        else
            log "ERROR: Failed to install $GL_ID"
        fi
    fi

    if [ "$GL32_INSTALLED" -lt 1 ]; then
        log "Installing $GL32_ID..."
        flatpak install -y --system flathub "$GL32_ID" >> "$LOG" 2>&1
        if [ $? -eq 0 ]; then
            log "Successfully installed $GL32_ID"
        else
            log "ERROR: Failed to install $GL32_ID"
        fi
    fi
fi

# --- STEP 2: Always check for and remove old mismatched runtimes ---
log "Checking for old NVIDIA flatpak runtimes to remove..."

OLD_RUNTIMES=$(flatpak list --system | grep -E "org\.freedesktop\.Platform\.(GL|GL32)\.nvidia" | grep -v "nvidia-${FLATPAK_VERSION}" | awk '{print $2}')

if [ -z "$OLD_RUNTIMES" ]; then
    log "No old runtimes found. All clean!"
else
    for RUNTIME in $OLD_RUNTIMES; do
        log "Removing old runtime: $RUNTIME"
        flatpak uninstall -y --system "$RUNTIME" >> "$LOG" 2>&1
        if [ $? -eq 0 ]; then
            log "Successfully removed $RUNTIME"
        else
            log "ERROR: Failed to remove $RUNTIME"
        fi
    done
fi

log "=== Sync Complete ==="
exit 0
