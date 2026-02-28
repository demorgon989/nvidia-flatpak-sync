# nvidia-flatpak-sync

Automatically keeps your Flatpak NVIDIA runtime in sync with your system NVIDIA driver on Fedora.

## The Problem

When Fedora updates your NVIDIA driver (via DNF/Discover), your Flatpak apps still reference the old NVIDIA runtime version. This causes errors like:

> Failed to get OpenGL information. Make sure your GPU drivers are properly installed.

This happens because DNF and Flatpak are completely separate ecosystems — they don't talk to each other. You have to manually install the new matching Flatpak NVIDIA runtime and remove the old one every time your driver updates. This tool fixes that.

## What It Does

On every boot, it:
1. Detects your current system NVIDIA driver version
2. Checks your installed Flatpak NVIDIA runtimes
3. If there's a mismatch — installs the correct runtime and removes the old one automatically
4. If everything matches — does nothing silently
5. Logs all actions to `/var/log/nvidia-flatpak-sync.log`

## Requirements

- Fedora (tested on Fedora 43 KDE)
- NVIDIA GPU with drivers installed via RPM Fusion
- Flatpak installed
- Flathub repository configured

## Installation

```bash
git clone https://github.com/demorgon989/nvidia-flatpak-sync.git
cd nvidia-flatpak-sync
chmod +x install.sh uninstall.sh nvidia-flatpak-sync.sh
sudo ./install.sh
```

That's it. The service will run automatically on every boot from now on.

## Checking the Log

To see what the service has done:

```bash
cat /var/log/nvidia-flatpak-sync.log
```

Example output after a driver update:
```
[2026-02-28 14:32:01] === NVIDIA Flatpak Sync Started ===
[2026-02-28 14:32:01] System NVIDIA driver version: 580.126.18
[2026-02-28 14:32:01] Expected flatpak runtime: org.freedesktop.Platform.GL.nvidia-580-126-18
[2026-02-28 14:32:01] Mismatch detected! Installing correct flatpak NVIDIA runtimes...
[2026-02-28 14:32:01] Installing org.freedesktop.Platform.GL.nvidia-580-126-18...
[2026-02-28 14:32:45] Successfully installed org.freedesktop.Platform.GL.nvidia-580-126-18
[2026-02-28 14:32:45] Installing org.freedesktop.Platform.GL32.nvidia-580-126-18...
[2026-02-28 14:33:10] Successfully installed org.freedesktop.Platform.GL32.nvidia-580-126-18
[2026-02-28 14:33:10] Removing old runtime: org.freedesktop.Platform.GL.nvidia-580-119-02
[2026-02-28 14:33:15] Successfully removed org.freedesktop.Platform.GL.nvidia-580-119-02
[2026-02-28 14:33:15] Removing old runtime: org.freedesktop.Platform.GL32.nvidia-580-119-02
[2026-02-28 14:33:20] Successfully removed org.freedesktop.Platform.GL32.nvidia-580-119-02
[2026-02-28 14:33:20] === Sync Complete ===
```

## Uninstallation

```bash
cd nvidia-flatpak-sync
chmod +x uninstall.sh
sudo ./uninstall.sh
```

## Running Manually

If you want to trigger a sync manually at any time:

```bash
sudo systemctl start nvidia-flatpak-sync.service
```

## How It Works

A bash script (`nvidia-flatpak-sync.sh`) is installed to `/usr/local/bin/` and a systemd service (`nvidia-flatpak-sync.service`) is enabled to run it at boot after network connectivity is established. The script uses `modinfo nvidia` to get the system driver version, converts it to Flatpak's naming format (dots to dashes), checks installed Flatpak runtimes, and installs/removes as needed.

## Contributing

Pull requests welcome! This was built to solve a real annoyance on Fedora with NVIDIA + Flatpak. If you've tested it on other distros or have improvements, feel free to open a PR.

## License

MIT
