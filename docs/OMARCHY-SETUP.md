# Home Manager Setup on Omarchy (Non-NixOS)

This guide explains how to use the standalone Home Manager configuration on your Omarchy machine.

## Prerequisites

1. **Install Nix Package Manager** on Omarchy:
   ```bash
   # Install Nix with flakes enabled
   sh <(curl -L https://nixos.org/nix/install) --daemon

   # Enable flakes and nix-command in your nix configuration
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. **Clone the configuration repository**:
   ```bash
   git clone <your-repo-url> ~/mycfg
   cd ~/mycfg
   ```

## Installation

### First-Time Setup

1. **Install Home Manager** using the standalone flake:
   ```bash
   cd ~/mycfg

   # For x86_64 systems
   nix run home-manager/master -- switch --flake ~/mycfg#todor -b backup

   # For ARM64/aarch64 systems
   nix run home-manager/master -- switch --flake ~/mycfg#todor-aarch64 -b backup
   ```

   The `-b backup` flag creates backups of any existing dotfiles that would be overwritten.

2. **Add Home Manager to your PATH** (add to `~/.bashrc` or `~/.zshrc`):
   ```bash
   export PATH="$HOME/.nix-profile/bin:$PATH"
   ```

3. **Reload your shell**:
   ```bash
   exec $SHELL
   ```

## Usage

### Applying Configuration Changes

After modifying any configuration files:

```bash
cd ~/mycfg

# Add new files to git (required for flakes)
git add .

# Apply changes (x86_64)
home-manager switch --flake ~/mycfg#todor

# Apply changes (aarch64)
home-manager switch --flake ~/mycfg#todor-aarch64
```

### Using the Standalone Flake

The standalone flake (`flake-home.nix`) is designed specifically for non-NixOS systems. To use it as the main flake:

```bash
# Option 1: Rename it to be the main flake
cd ~/mycfg
mv flake.nix flake-nixos.nix     # Keep NixOS flake as backup
mv flake-home.nix flake.nix      # Use home-manager flake

# Option 2: Use it directly without renaming
home-manager switch --flake ~/mycfg/flake-home.nix#todor
```

### Updating Packages

```bash
cd ~/mycfg

# Update flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Apply updated configuration
home-manager switch --flake ~/mycfg#todor
```

### Rolling Back Changes

If something breaks:

```bash
# List previous generations
home-manager generations

# Rollback to previous generation
home-manager generations | head -2 | tail -1 | awk '{print $NF}' | xargs -I{} {}/activate
```

## Differences from NixOS Setup

### What Works
- All user packages and applications
- Dotfiles and configuration files
- Development tools (git, nvim, zsh, etc.)
- Terminal emulators (Ghostty, Kitty)
- Desktop applications (Brave, Spotify, etc.)
- Niri and Hyprland configurations (if Wayland is available on Omarchy)

### What Might Need Adjustment

1. **Window Manager Integration**: If Omarchy doesn't use Wayland or has different session management:
   - Niri/Hyprland might not work out of the box
   - You may need to disable window manager modules

2. **System Services**: Some systemd user services might need adjustment:
   - Check `systemctl --user status` to see what's running

3. **Fonts**: System fonts installed via NixOS won't be available:
   - Home Manager will install fonts to `~/.local/share/fonts/`
   - You may need to run `fc-cache -f` to refresh font cache

### Disabling Modules for Omarchy

If certain modules don't work well on Omarchy, you can disable them:

```bash
# Edit home/todor/default.nix and comment out problematic imports
vim ~/mycfg/home/todor/default.nix

# For example, to disable niri:
# imports = [
#   ./modules/development.nix
#   # ./modules/niri.nix    # Disabled for Omarchy
#   ...
# ];
```

## Troubleshooting

### Nix Daemon Not Running
```bash
# Check if nix-daemon is running
systemctl status nix-daemon

# Start it if needed
sudo systemctl start nix-daemon
```

### Permission Issues
```bash
# Fix nix store permissions
sudo chown -R root:nixbld /nix
sudo chmod 1775 /nix/store
```

### Flake Errors
```bash
# Ensure all files are tracked by git
git add .
git status

# Update flake lock
nix flake update

# Check flake is valid
nix flake check
```

### Profile Not in PATH
```bash
# Add to your shell RC file (~/.bashrc or ~/.zshrc)
export PATH="$HOME/.nix-profile/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
```

## Keeping Configuration in Sync

To keep your Omarchy and NixOS configurations in sync:

1. **Use Git** to track changes:
   ```bash
   cd ~/mycfg
   git pull   # Get latest changes
   git add .
   git commit -m "Update config"
   git push   # Share changes
   ```

2. **Test changes** on one machine before applying to others

3. **Use conditional logic** for machine-specific settings:
   ```nix
   # In your config files
   programs.foo.enable = lib.mkIf (!config.isOmarchy) true;
   ```

## Uninstalling

If you need to remove Home Manager:

```bash
# Remove Home Manager generations
home-manager expire-generations "-1 days"

# Uninstall Home Manager
nix-env -e home-manager

# Remove Nix entirely (optional)
sudo /nix/nix-installer uninstall
```

## Additional Resources

- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Package Search](https://search.nixos.org/packages)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
