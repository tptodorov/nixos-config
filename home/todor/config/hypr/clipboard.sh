#!/usr/bin/env bash

# Clipboard Manager Script for Hyprland/Niri
# Uses cliphist and tofi to provide a nice clipboard history interface

# Lock file to prevent multiple instances
LOCK_FILE="/tmp/clipboard_manager.lock"

# Check if another instance is running
if [[ -f "$LOCK_FILE" ]]; then
    # Check if the process is still running
    if ps -p $(cat "$LOCK_FILE") > /dev/null 2>&1; then
        exit 0
    else
        # Stale lock file, remove it
        rm -f "$LOCK_FILE"
    fi
fi

# Create lock file with current PID
echo $$ > "$LOCK_FILE"

# Cleanup function to remove lock file on exit
cleanup() {
    rm -f "$LOCK_FILE"
}
trap cleanup EXIT

# Check if cliphist is available
if ! command -v cliphist &> /dev/null; then
    notify-send "Clipboard Manager" "cliphist is not installed" -u critical
    exit 1
fi

# Check if tofi is available
if ! command -v tofi &> /dev/null; then
    notify-send "Clipboard Manager" "tofi is not installed" -u critical
    exit 1
fi

# Function to show clipboard history
show_clipboard_history() {
    local selected
    # Use tofi for clipboard history selection
    selected=$(cliphist list | tofi \
        --prompt-text "Clipboard History: " \
        --fuzzy-match=true \
        --require-match=false)

    if [[ -n "$selected" ]]; then
        # Decode and copy to clipboard
        echo "$selected" | cliphist decode | wl-copy
        notify-send "Clipboard Manager" "Item copied to clipboard" -t 2000
    fi
}

# Function to clear clipboard history
clear_clipboard_history() {
    local confirm
    confirm=$(echo -e "Yes\nNo" | tofi \
        --prompt-text "Clear clipboard history? ")

    if [[ "$confirm" == "Yes" ]]; then
        cliphist wipe
        notify-send "Clipboard Manager" "Clipboard history cleared" -t 2000
    fi
}

# Function to delete a specific item
delete_clipboard_item() {
    local selected
    selected=$(cliphist list | tofi \
        --prompt-text "Select item to delete: " \
        --fuzzy-match=true \
        --require-match=false)

    if [[ -n "$selected" ]]; then
        echo "$selected" | cliphist delete
        notify-send "Clipboard Manager" "Item deleted from history" -t 2000
    fi
}

# Main function with action menu
main_menu() {
    local action
    action=$(echo -e "📋 Show History\n🗑️  Clear All\n❌ Delete Item" | tofi \
        --prompt-text "Clipboard Manager: ")

    case "$action" in
        "📋 Show History")
            show_clipboard_history
            ;;
        "🗑️  Clear All")
            clear_clipboard_history
            ;;
        "❌ Delete Item")
            delete_clipboard_item
            ;;
    esac
}

# Parse command line arguments
case "${1:-}" in
    --history|-h)
        show_clipboard_history
        ;;
    --clear|-c)
        clear_clipboard_history
        ;;
    --delete|-d)
        delete_clipboard_item
        ;;
    --menu|-m|*)
        # Default action - show history directly
        show_clipboard_history
        ;;
esac
