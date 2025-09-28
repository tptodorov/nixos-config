#!/usr/bin/env bash

# Clipboard Manager Script for Hyprland
# Uses cliphist and wofi to provide a nice clipboard history interface

# Check if cliphist is available
if ! command -v cliphist &> /dev/null; then
    notify-send "Clipboard Manager" "cliphist is not installed" -u critical
    exit 1
fi

# Check if wofi is available
if ! command -v wofi &> /dev/null; then
    notify-send "Clipboard Manager" "wofi is not installed" -u critical
    exit 1
fi

# Function to show clipboard history
show_clipboard_history() {
    local selected
    selected=$(cliphist list | wofi \
        --dmenu \
        --prompt "Clipboard History" \
        --width 800 \
        --height 400 \
        --lines 10 \
        --cache-file /dev/null \
        --parse-search \
        --matching contains \
        --insensitive \
        --style ~/.config/wofi/clipboard.css 2>/dev/null || \
        cliphist list | wofi \
        --dmenu \
        --prompt "Clipboard History" \
        --width 800 \
        --height 400 \
        --lines 10 \
        --cache-file /dev/null \
        --parse-search \
        --matching contains \
        --insensitive)

    if [[ -n "$selected" ]]; then
        # Decode and copy to clipboard
        echo "$selected" | cliphist decode | wl-copy
        notify-send "Clipboard Manager" "Item copied to clipboard" -t 2000
    fi
}

# Function to clear clipboard history
clear_clipboard_history() {
    local confirm
    confirm=$(echo -e "Yes\nNo" | wofi \
        --dmenu \
        --prompt "Clear clipboard history?" \
        --width 300 \
        --height 150 \
        --lines 2 \
        --cache-file /dev/null)

    if [[ "$confirm" == "Yes" ]]; then
        cliphist wipe
        notify-send "Clipboard Manager" "Clipboard history cleared" -t 2000
    fi
}

# Function to delete a specific item
delete_clipboard_item() {
    local selected
    selected=$(cliphist list | wofi \
        --dmenu \
        --prompt "Select item to delete" \
        --width 800 \
        --height 400 \
        --lines 10 \
        --cache-file /dev/null \
        --parse-search \
        --matching contains \
        --insensitive)

    if [[ -n "$selected" ]]; then
        echo "$selected" | cliphist delete
        notify-send "Clipboard Manager" "Item deleted from history" -t 2000
    fi
}

# Main function with action menu
main_menu() {
    local action
    action=$(echo -e "📋 Show History\n🗑️  Clear All\n❌ Delete Item" | wofi \
        --dmenu \
        --prompt "Clipboard Manager" \
        --width 250 \
        --height 180 \
        --lines 3 \
        --cache-file /dev/null)

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
