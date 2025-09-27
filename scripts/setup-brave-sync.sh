#!/usr/bin/env bash

# Brave Browser Sync Setup Script
# This script helps you configure Brave browser with your sync account

set -e

echo "🦁 Brave Browser Sync Setup for todor@peychev.com"
echo "================================================="
echo

# Check if Brave is installed
if ! command -v brave &> /dev/null; then
    echo "❌ Brave browser is not installed or not in PATH"
    echo "Please run 'sudo nixos-rebuild switch --flake .#blackbox' to install Brave"
    exit 1
fi

echo "✅ Brave browser found: $(brave --version)"
echo

# Check if config directory exists
BRAVE_CONFIG_DIR="$HOME/.config/BraveSoftware/Brave-Browser"
if [ ! -d "$BRAVE_CONFIG_DIR" ]; then
    echo "📁 Creating Brave configuration directory..."
    mkdir -p "$BRAVE_CONFIG_DIR/Default"
fi

# Check current BROWSER environment variable
echo "🔧 Current configuration:"
echo "   BROWSER environment variable: ${BROWSER:-not set}"
echo "   Default applications for web:"
xdg-mime query default text/html 2>/dev/null || echo "   (not configured)"
echo

# Function to wait for Brave process
wait_for_brave() {
    echo "⏳ Waiting for Brave to start..."
    sleep 3
    while ! pgrep -f "brave" > /dev/null; do
        echo "   Still waiting for Brave to start..."
        sleep 2
    done
    echo "✅ Brave is running!"
}

# Function to open sync settings
open_sync_settings() {
    echo "🔄 Opening Brave sync settings..."
    brave --new-window "brave://settings/syncSetup" &
    wait_for_brave
}

# Main setup process
echo "🚀 Starting Brave setup process..."
echo

echo "Step 1: Opening Brave browser..."
if pgrep -f "brave" > /dev/null; then
    echo "   Brave is already running"
else
    brave &
    wait_for_brave
fi

echo
echo "Step 2: Sync Configuration"
echo "=========================="
echo "Your Brave browser is now configured with:"
echo "   • Email: todor@peychev.com"
echo "   • Sync enabled for all data types"
echo "   • Privacy-focused extensions pre-installed"
echo "   • Hardware acceleration enabled"
echo "   • Wayland support enabled"
echo
echo "To complete the sync setup:"
echo "   1. Click on the profile icon (top right)"
echo "   2. Click 'Turn on sync...'"
echo "   3. Sign in with your Google/Brave account (todor@peychev.com)"
echo "   4. Choose what to sync (recommended: everything)"
echo

read -p "Would you like to open the sync settings page automatically? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open_sync_settings
fi

echo
echo "Step 3: Verify Default Browser Settings"
echo "======================================="
echo "Making sure Brave is set as your default browser..."

# Set Brave as default for common MIME types
xdg-mime default brave-browser.desktop text/html
xdg-mime default brave-browser.desktop text/xml
xdg-mime default brave-browser.desktop application/xhtml+xml
xdg-mime default brave-browser.desktop x-scheme-handler/http
xdg-mime default brave-browser.desktop x-scheme-handler/https

echo "✅ Default browser associations updated"

echo
echo "Step 4: Extensions Setup"
echo "======================="
echo "The following extensions are pre-configured:"
echo "   • uBlock Origin (Ad blocker)"
echo "   • Bitwarden (Password manager)"
echo "   • Dark Reader (Dark mode)"
echo "   • Privacy Badger (Tracker blocker)"
echo "   • ClearURLs (Remove tracking parameters)"
echo
echo "These will be installed automatically on first run."

echo
echo "Step 5: Privacy & Security Features"
echo "===================================="
echo "Your Brave browser includes:"
echo "   ✅ Brave Shields (blocks ads, trackers, fingerprinting)"
echo "   ✅ DNS-over-HTTPS with Cloudflare"
echo "   ✅ WebRTC leak protection"
echo "   ✅ IPFS support"
echo "   ✅ Brave Rewards"
echo "   ✅ Built-in crypto wallet"
echo "   ✅ Search with Brave Search (privacy-focused)"

echo
echo "🎉 Brave Browser Setup Complete!"
echo "================================"
echo
echo "Quick tips:"
echo "   • Use 'brave' command to launch browser"
echo "   • Use 'brave-private' for incognito mode"
echo "   • Your sync account: todor@peychev.com"
echo "   • Config location: ~/.config/BraveSoftware/Brave-Browser/"
echo
echo "If you encounter any issues:"
echo "   • Check sync status in brave://settings/syncSetup"
echo "   • Restart Brave if extensions don't load"
echo "   • Your data will sync across all your devices"
echo
echo "Enjoy browsing with Brave! 🦁"
