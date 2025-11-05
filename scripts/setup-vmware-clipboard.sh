#!/usr/bin/env bash

# VMware Clipboard Setup Script for vm-aarch64
# This script helps set up VMware Tools clipboard functionality

set -e

echo "🔧 Setting up VMware clipboard functionality for vm-aarch64..."

# Check if we're running in the VM
if [[ "$(hostname)" != "vm-aarch64" ]]; then
    echo "❌ This script should be run inside the vm-aarch64 VM"
    echo "💡 Use 'make vm/login' to connect to the VM first"
    exit 1
fi

# Check if we're running as root or with sudo
if [[ $EUID -ne 0 ]]; then
    echo "❌ This script needs to be run as root or with sudo"
    echo "💡 Run: sudo $0"
    exit 1
fi

echo "📦 Rebuilding NixOS configuration with VMware Tools..."
NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake "/nix-config#vm-aarch64"

echo "🔄 Checking VMware Tools services..."

# Check if open-vm-tools service is running
if systemctl is-active --quiet open-vm-tools; then
    echo "✅ open-vm-tools service is running"
else
    echo "🔄 Starting open-vm-tools service..."
    systemctl start open-vm-tools
    systemctl enable open-vm-tools
fi

# Check if vmtoolsd is running
if pgrep -x "vmtoolsd" > /dev/null; then
    echo "✅ vmtoolsd daemon is running"
else
    echo "⚠️  vmtoolsd daemon is not running"
fi

echo "🖥️  Checking display and clipboard services..."

# For Wayland (Hyprland), check if wl-clipboard is available
if command -v wl-copy &> /dev/null && command -v wl-paste &> /dev/null; then
    echo "✅ wl-clipboard tools are available"
else
    echo "❌ wl-clipboard tools are not available"
fi

# For X11 fallback, check if xclip is available
if command -v xclip &> /dev/null; then
    echo "✅ xclip is available for X11 clipboard"
else
    echo "❌ xclip is not available"
fi

echo ""
echo "🎯 Setup complete! To test clipboard functionality:"
echo "   1. Copy some text on your host machine"
echo "   2. In the VM, try pasting with Ctrl+V or middle-click"
echo "   3. Copy text in the VM and try pasting on the host"
echo ""
echo "📝 Notes:"
echo "   - Make sure 'Copy and Paste' is enabled in VMware Fusion settings"
echo "   - In VMware Fusion: VM > Settings > Sharing > Enable clipboard sharing"
echo "   - For Hyprland, clipboard history is available with Super+V"
echo ""
echo "🔧 If clipboard still doesn't work, try:"
echo "   - Restart the VM: sudo reboot"
echo "   - Check VMware Fusion clipboard settings"
echo "   - Ensure VMware Tools are properly installed in the guest"
echo ""
echo "💡 This script was run inside the VM. The configuration was applied using:"
echo "   make vm/bootstrap  # (from the host machine)"
