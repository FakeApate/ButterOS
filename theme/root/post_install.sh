#!/bin/bash

set -e

# === chezmoi installation ===
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "[+] Installing chezmoi..."
    wget get.chezmoi.io -O /tmp/install.sh
    chmod +x /tmp/install.sh
    chown sam:sam /tmp/install.sh
    su - sam -c "bash /tmp/install.sh -- init --apply FakeApate"
else
    echo "[✓] chezmoi already installed"
fi

# === VS Code installation ===
if ! rpm -q code >/dev/null 2>&1; then
    echo "[+] Installing VS Code..."
    wget https://code.visualstudio.com/sha/download?build=stable&os=linux-rpm-x64 -O /tmp/code.rpm
    dnf install -y /tmp/code.rpm
else
    echo "[✓] VS Code already installed"
fi

# === System update ===
echo "[+] Running system update..."
dnf update -y

# === Reboot check ===
if command -v need-restarting >/dev/null 2>&1; then
    if need-restarting -r >/dev/null 2>&1; then
        echo "[!] Reboot required. Rebooting in 10 seconds..."
        sleep 10
        reboot
    else
        echo "[✓] No reboot needed"
    fi
else
    echo "[?] need-restarting not found. Skipping reboot check"
fi

# === NVIDIA Driver installation ===
if ! rpm -q akmod-nvidia >/dev/null 2>&1; then
    echo "[+] Installing NVIDIA drivers..."
    dnf install -y akmod-nvidia
    dnf install -y xorg-x11-drv-nvidia-cuda
else
    echo "[✓] NVIDIA drivers already installed"
fi