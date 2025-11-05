#!/usr/bin/env bash

# Test script for Sway display configuration on vm-aarch64
# This script helps verify that Sway is using the correct display settings

echo "=== Sway Display Configuration Test ==="
echo

# Check if Sway is running
if ! pgrep -x sway > /dev/null; then
    echo "❌ Sway is not currently running"
    echo "   Please start Sway and run this script again"
    exit 1
fi

echo "✅ Sway is running"
echo

# Check display outputs using wlr-randr
echo "=== Display Information (wlr-randr) ==="
if command -v wlr-randr > /dev/null; then
    wlr-randr
else
    echo "❌ wlr-randr not found"
fi
echo

# Check display outputs using swaymsg
echo "=== Sway Output Information ==="
if command -v swaymsg > /dev/null; then
    swaymsg -t get_outputs | jq -r '.[] | "Output: \(.name) | Mode: \(.current_mode.width)x\(.current_mode.height)@\(.current_mode.refresh/1000)Hz | Scale: \(.scale) | Transform: \(.transform)"'
else
    echo "❌ swaymsg not found"
fi
echo

# Check environment variables
echo "=== Environment Variables ==="
echo "GDK_SCALE: ${GDK_SCALE:-not set}"
echo "QT_SCALE_FACTOR: ${QT_SCALE_FACTOR:-not set}"
echo "XCURSOR_SIZE: ${XCURSOR_SIZE:-not set}"
echo "WLR_NO_HARDWARE_CURSORS: ${WLR_NO_HARDWARE_CURSORS:-not set}"
echo

# Check available display modes
echo "=== Available Display Modes ==="
if [ -f /sys/class/drm/card0*/modes ]; then
    echo "Top 10 available modes:"
    cat /sys/class/drm/card0*/modes 2>/dev/null | head -10
else
    echo "❌ Cannot read display modes"
fi
echo

# Check Sway configuration
echo "=== Sway Configuration (output section) ==="
if [ -f ~/.config/sway/config ]; then
    grep -A5 -B2 "output" ~/.config/sway/config
else
    echo "❌ Sway config not found"
fi
echo

echo "=== Test Complete ==="
echo "If you're experiencing scaling issues:"
echo "1. Try logging out and back in to Sway"
echo "2. Check that applications respect the scaling environment variables"
echo "3. Some applications may need to be restarted to pick up scaling changes"
