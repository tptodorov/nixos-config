#!/usr/bin/env bash
# Sync NixOS LazyVim configuration to local machine

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NVIM_CONFIG_SRC="$REPO_DIR/home/todor/config/nvim"
NVIM_CONFIG_DST="$HOME/.config/nvim"
BACKUP_DIR="$HOME/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)"

echo "🔄 Syncing LazyVim configuration from NixOS setup..."
echo "  Source: $NVIM_CONFIG_SRC"
echo "  Destination: $NVIM_CONFIG_DST"

# Backup existing config if it exists
if [[ -e "$NVIM_CONFIG_DST" && ! -L "$NVIM_CONFIG_DST" ]]; then
    echo "📦 Backing up existing config to $BACKUP_DIR"
    mv "$NVIM_CONFIG_DST" "$BACKUP_DIR"
fi

# Remove symlink if it exists and points to old location
if [[ -L "$NVIM_CONFIG_DST" ]]; then
    echo "🔗 Removing old symlink"
    rm "$NVIM_CONFIG_DST"
fi

# Copy config
if [[ -d "$NVIM_CONFIG_SRC" ]]; then
    echo "📋 Copying configuration..."
    cp -r "$NVIM_CONFIG_SRC" "$NVIM_CONFIG_DST"
    echo "✅ Configuration copied"
else
    echo "❌ Error: Source config not found at $NVIM_CONFIG_SRC"
    exit 1
fi

# Ensure data directory exists for lazy.nvim
mkdir -p "$HOME/.local/share/nvim/lazy"

# Initialize lazy.nvim
echo "⚙️  Initializing lazy.nvim..."
nvim --headless "+Lazy! sync" +qa || true

echo ""
echo "✨ LazyVim setup complete!"
echo ""
echo "Next steps:"
echo "  1. Open nvim: nvim"
echo "  2. Run :Lazy update to get the latest plugins"
echo "  3. Run :Mason to install language servers as needed"
echo ""
if [[ -e "$BACKUP_DIR" ]]; then
    echo "Previous config backed up to: $BACKUP_DIR"
fi
