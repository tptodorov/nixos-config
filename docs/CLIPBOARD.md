# Clipboard Manager Setup

This document describes the clipboard manager configuration for your Hyprland setup using `cliphist` and `wofi`.

## Overview

The clipboard manager provides a searchable history of copied text and images, accessible via the `SUPER+V` keyboard shortcut. It uses:

- **cliphist**: A clipboard history manager for Wayland
- **wl-clipboard**: Wayland clipboard utilities
- **wofi**: Application launcher/dmenu for the clipboard interface

## Features

- 📋 **History Access**: Press `SUPER+V` to view and select from clipboard history
- 🖼️ **Image Support**: Stores both text and image clipboard content
- 🔍 **Search**: Type to filter clipboard entries
- 🎨 **Custom Styling**: Beautiful UI with custom CSS theming
- 🗑️ **Management**: Options to clear history or delete specific items

## Keybindings

| Key Combination | Action |
|----------------|--------|
| `SUPER+V` | Open clipboard history |
| `SUPER+F11` | Toggle floating window (moved from SUPER+V) |

## How It Works

1. **Background Service**: The clipboard daemon runs automatically on login via Hyprland's `exec-once` commands:
   ```
   exec-once = wl-paste --type text --watch cliphist store
   exec-once = wl-paste --type image --watch cliphist store
   ```

2. **Interface**: When you press `SUPER+V`, it launches a custom script that:
   - Shows clipboard history in a wofi menu
   - Allows searching/filtering entries
   - Copies selected item back to clipboard

## Usage

### Basic Usage
1. Copy text or images as usual (`Ctrl+C`)
2. Press `SUPER+V` to open clipboard history
3. Type to search, use arrow keys to navigate
4. Press `Enter` to select and copy an item

### Advanced Features
The clipboard script supports additional modes (can be run from terminal):

```bash
# Show clipboard history (default)
~/.config/hypr/clipboard.sh

# Clear all clipboard history
~/.config/hypr/clipboard.sh --clear

# Delete specific item
~/.config/hypr/clipboard.sh --delete
```

## Files and Configuration

### Package Installation
- Packages defined in: `home/todor/modules/hyprland.nix`
- Includes: `cliphist`, `wl-clipboard`

### Configuration Files
- **Script**: `home/todor/config/hypr/clipboard.sh` - Main clipboard manager script
- **Styling**: `home/todor/config/wofi/clipboard.css` - Custom wofi theme
- **Keybinds**: `home/todor/config/hypr/hyprland.conf` - Hyprland key bindings

### Hyprland Integration
The clipboard manager is integrated into Hyprland configuration:
- Auto-start clipboard daemon on login
- Custom keybinding for `SUPER+V`
- Notification support via `mako`

## Customization

### Modify Appearance
Edit `~/.config/wofi/clipboard.css` to customize the look:
- Colors and transparency
- Fonts and sizing
- Border styles and animations

### Change Keybinding
Edit `hyprland.conf` to change the keybinding:
```
bind = $mainMod, V, exec, ~/.config/hypr/clipboard.sh
```

### Adjust History Size
Modify the cliphist command in the script to limit history:
```bash
# Limit to 50 items
cliphist list -n 50
```

## Troubleshooting

### Clipboard Manager Not Working
1. Check if services are running:
   ```bash
   pgrep -f "wl-paste.*cliphist"
   ```

2. Test cliphist directly:
   ```bash
   cliphist list
   ```

3. Restart Hyprland to pick up the new `exec-once` commands:
   ```bash
   # Log out and back in, or restart Hyprland
   hyprctl dispatch exit
   ```

### Empty Clipboard History
- The clipboard starts empty - copy some text first
- Check if `wl-paste` and `cliphist` are in PATH
- Verify the daemon started with Hyprland

### Wofi Not Appearing
- Check if wofi is installed and accessible
- Test wofi directly: `echo "test" | wofi --dmenu`
- Check for conflicting keybindings

## Technical Details

### Storage Location
Clipboard history is stored in: `~/.local/share/cliphist/`

### Dependencies
- `hyprland` - Window manager
- `cliphist` - Clipboard history manager
- `wl-clipboard` - Wayland clipboard utilities
- `wofi` - Application launcher/menu
- `mako` - Notification daemon (for status messages)

### Security Note
Clipboard history is stored locally and includes all copied content. Be mindful of sensitive information like passwords (consider using a proper password manager).

## Getting Started

After applying this configuration:

1. **First Time Setup**: Log out and back into Hyprland to start the clipboard daemon
2. **Test**: Copy some text, then press `SUPER+V` to see if the clipboard history appears
3. **Verify**: Check that both text and images are being stored in the history

The clipboard manager will start automatically on subsequent logins.
