# Standalone Home Manager Setup

Use this configuration on **non-NixOS systems** (Omarchy, Ubuntu, Fedora, etc.) to get the same user environment and dotfiles.

## Quick Start

### 1. Install Nix
```bash
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 2. Clone This Repository
```bash
git clone <your-repo-url> ~/mycfg
cd ~/mycfg
```

### 3. Install Home Manager
```bash
# For x86_64 systems (most PCs)
nix run home-manager/master -- switch --flake ~/mycfg#todor -b backup

# For ARM64 systems (Raspberry Pi, some laptops)
nix run home-manager/master -- switch --flake ~/mycfg#todor-aarch64 -b backup
```

### 4. Update Your Shell
Add to `~/.bashrc` or `~/.zshrc`:
```bash
export PATH="$HOME/.nix-profile/bin:$PATH"
```

Then reload:
```bash
exec $SHELL
```

## Daily Usage

### Apply Configuration Changes
```bash
cd ~/mycfg
git add .                              # Add new files
home-manager switch --flake ~/mycfg#todor  # Apply
```

### Update Packages
```bash
cd ~/mycfg
nix flake update                       # Update package sources
home-manager switch --flake ~/mycfg#todor  # Apply updates
```

### Rollback if Something Breaks
```bash
home-manager generations               # List previous versions
# Use the activate script from the generation you want
```

## What You Get

- **Development Tools**: git, neovim (LazyVim), zed, direnv, ripgrep, fd, etc.
- **Terminal**: Ghostty, Kitty, Rio with configured themes
- **Shell**: Zsh with Oh My Zsh
- **Desktop Apps**: Brave browser, Spotify, media tools
- **Window Managers**: Niri and Hyprland configs (if your system supports Wayland)
- **All Dotfiles**: Unified configuration across all your machines

## Customization

### Disable Modules
Edit `home/todor/default.nix` and comment out modules you don't need:
```nix
imports = [
  ./modules/development.nix
  # ./modules/niri.nix     # Disable if not using Wayland
  ./modules/terminal.nix
  # ...
];
```

### Add Machine-Specific Settings
Create a file `home/todor/modules/omarchy.nix` for Omarchy-specific configs.

## Detailed Documentation

See `docs/OMARCHY-SETUP.md` for complete instructions, troubleshooting, and advanced usage.

## File Structure

- `flake-home.nix` - Standalone Home Manager flake (non-NixOS)
- `flake.nix` - Full NixOS system configuration
- `home/todor/` - User configuration and dotfiles
- `docs/OMARCHY-SETUP.md` - Detailed setup guide
