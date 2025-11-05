#!/usr/bin/env bash

# Test Brave Browser in VM
# This script helps diagnose Brave browser issues in the vm-aarch64 instance

set -e

echo "🦁 Testing Brave Browser in VM..."

# Check if we're running in the VM
if [[ "$(hostname)" != "vm-aarch64" ]]; then
    echo "❌ This script should be run inside the vm-aarch64 VM"
    echo "💡 Use 'make vm/login' to connect to the VM first"
    exit 1
fi

echo "📋 System Information:"
echo "  Hostname: $(hostname)"
echo "  Architecture: $(uname -m)"
echo "  Kernel: $(uname -r)"
echo ""

echo "🔍 Checking Brave Installation:"
if command -v brave &> /dev/null; then
    echo "  ✅ Brave found at: $(which brave)"
    echo "  📦 Version: $(brave --version 2>/dev/null || echo 'Version check failed')"
else
    echo "  ❌ Brave not found in PATH"
    exit 1
fi

echo ""
echo "🖥️  Display Environment:"
echo "  DISPLAY: ${DISPLAY:-'not set'}"
echo "  WAYLAND_DISPLAY: ${WAYLAND_DISPLAY:-'not set'}"
echo "  XDG_SESSION_TYPE: ${XDG_SESSION_TYPE:-'not set'}"
echo "  XDG_CURRENT_DESKTOP: ${XDG_CURRENT_DESKTOP:-'not set'}"

echo ""
echo "🔄 Checking Display Processes:"
if pgrep -f hyprland > /dev/null; then
    echo "  ✅ Hyprland is running"
else
    echo "  ❌ Hyprland is not running"
fi

if pgrep -f gdm > /dev/null; then
    echo "  ✅ GDM is running"
else
    echo "  ❌ GDM is not running"
fi

echo ""
echo "🧪 Testing Brave Launch (headless):"
timeout 10s brave --no-sandbox --disable-gpu --headless --disable-dev-shm-usage --virtual-time-budget=1000 --run-all-compositor-stages-before-draw --dump-dom "data:text/html,<h1>Test</h1>" 2>&1 | head -10 || echo "Headless test completed"

echo ""
echo "📝 Brave Configuration Check:"
if [[ -f ~/.config/BraveSoftware/Brave-Browser/Default/Preferences ]]; then
    echo "  ✅ Brave profile exists"
else
    echo "  ⚠️  No Brave profile found (first run needed)"
fi

echo ""
echo "🔧 Suggested Solutions:"
echo "  1. Launch Brave from within Hyprland session (not SSH)"
echo "  2. Use: Super+Return to open terminal, then type 'brave'"
echo "  3. Or use: Super+Alt+Space to open wofi, then type 'brave'"
echo "  4. Check VMware 3D acceleration is working"
echo ""
echo "🚀 To test Brave properly:"
echo "  - Switch to the VM's desktop (not SSH)"
echo "  - Press Super+Return to open terminal"
echo "  - Type: brave --no-sandbox"
echo "  - Or press Super+Alt+Space and type 'brave'"
