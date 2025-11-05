#!/usr/bin/env bash

# Test Brave Browser from Desktop Session
# Run this script from within the VM's desktop (not SSH)

echo "🦁 Brave Browser Desktop Test"
echo "=============================="
echo ""

# Check if we're in a graphical session
if [[ -z "$WAYLAND_DISPLAY" && -z "$DISPLAY" ]]; then
    echo "❌ No display environment detected!"
    echo "💡 This script must be run from within the VM's desktop session"
    echo "   1. Switch to your VM window"
    echo "   2. Press Super+Return to open terminal"
    echo "   3. Run this script again"
    exit 1
fi

echo "✅ Running in graphical session"
echo "   WAYLAND_DISPLAY: $WAYLAND_DISPLAY"
echo "   DISPLAY: $DISPLAY"
echo "   XDG_SESSION_TYPE: $XDG_SESSION_TYPE"
echo ""

# Check scaling environment
echo "🖥️  Display Scaling:"
echo "   GDK_SCALE: $GDK_SCALE"
echo "   QT_SCALE_FACTOR: $QT_SCALE_FACTOR"
echo ""

# Check if Brave is available
if ! command -v brave &> /dev/null; then
    echo "❌ Brave not found in PATH"
    exit 1
fi

echo "📦 Brave Information:"
echo "   Location: $(which brave)"
echo "   Version: $(brave --version)"
echo ""

# Test Brave launch
echo "🚀 Testing Brave Launch..."
echo "   Launching Brave browser..."

# Launch Brave with appropriate flags for VM
brave --no-sandbox --disable-dev-shm-usage &
BRAVE_PID=$!

# Wait a moment for Brave to start
sleep 3

# Check if Brave is running
if ps -p $BRAVE_PID > /dev/null 2>&1; then
    echo "✅ Brave launched successfully!"
    echo "   Process ID: $BRAVE_PID"
    echo "   You should see Brave window on your screen"
else
    echo "❌ Brave failed to launch"
    echo "   Check the terminal for error messages"
fi

echo ""
echo "🎯 Test Results:"
echo "   - If Brave window appeared: ✅ Success!"
echo "   - If no window appeared: ❌ Issue with display/graphics"
echo "   - Check window decorations and scaling"
echo ""
echo "💡 Tips:"
echo "   - Brave should have proper window title bar"
echo "   - Text should be crisp with 2x scaling"
echo "   - Try copying/pasting between host and VM"
