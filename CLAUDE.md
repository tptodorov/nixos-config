# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a NixOS system configuration repository using Nix Flakes for declarative system and user environment management. It supports **multiple hosts** (blackbox, pero, vm-aarch64) and **multiple users** with reusable configuration profiles. The modular structure makes it easy to add new machines and user accounts.

## Common Commands

### System Management
```bash
# Rebuild and switch NixOS system configuration
sudo nixos-rebuild switch --flake .#blackbox  # On blackbox
sudo nixos-rebuild switch --flake .#pero      # On pero (MacBook Pro)

# Test system configuration without switching
sudo nixos-rebuild test --flake .#blackbox

# Rebuild user environment with Home Manager
home-manager switch --flake .

# Update flake inputs
nix flake update

# Check flake configuration
nix flake check

# Build a specific host configuration without switching
nixos-rebuild build --flake .#pero
```

### Development
```bash
# Enter development shell (if devenv is configured)
direnv allow  # if .envrc exists

# Git operations (lazygit is available)
lazygit

# Search files and content
rg <pattern>  # ripgrep for content search
```

## Architecture

### Configuration Structure

This repository is structured to support **multiple NixOS hosts** and **multiple users**.

#### Core Files
- **`flake.nix`**: Main flake configuration defining inputs and outputs for all hosts

#### Configuration Profiles (Reusable)
- **`modules/profiles/`**: Shared configuration profiles that can be imported by any host
  - `base.nix`: Essential system configuration (Nix settings, SSH, basic packages, garbage collection)
  - `desktop.nix`: Full desktop environment (GNOME, COSMIC, Hyprland, Niri, hardware acceleration)
  - `laptop.nix`: Laptop-specific features (power management, TLP, touchpad, lid switch handling)

#### Host Configurations
- **`hosts/blackbox/`**: Desktop workstation configuration
  - `default.nix`: Host configuration (imports base + desktop profiles)
  - `hardware-configuration.nix`: Hardware-specific configuration
  - `modules/`: Host-specific modules (networking, services)
- **`hosts/pero/`**: MacBook Pro 13" 2017 configuration
  - `default.nix`: Host configuration (imports base + laptop + desktop profiles)
  - `hardware-configuration.nix`: Hardware-specific configuration (placeholder until NixOS is installed)
  - `modules/macbook.nix`: Apple hardware-specific settings (keyboard, trackpad, display scaling)
- **`hosts/vm-aarch64/`**: ARM64 VM configuration

#### User Configurations
- **`modules/users/`**: User account definitions (can be reused across hosts)
  - `todor.nix`: User account configuration with default password "todor"
- **`home/todor/`**: Home Manager configuration for user todor
  - `default.nix`: User packages, dotfiles, and application configs
  - `modules/`: Modular user configurations
    - `niri.nix`: Niri window manager configuration
    - `hyprland.nix`: Hyprland window manager configuration
    - `terminal.nix`: Terminal emulator configurations
    - `development.nix`: Development tools and settings
    - `nixvim.nix`: Neovim configuration
    - `brave.nix`: Browser configuration
    - Other module files
  - `config/`: Static configuration files
    - `hypr/`: Hyprland scripts and configs
    - `waybar/`: Waybar styling and configurations
    - `wofi/`: Wofi launcher styling
    - `nvim/`: Neovim configs

#### Shared Modules
- **`modules/common/`**: Truly common modules (fonts, etc.)

### Technology Stack
- **OS**: NixOS 25.05
- **Package Manager**: Nix with Flakes
- **Desktop**: Multiple Wayland compositors available:
  - **Niri** - Scrollable-tiling Wayland compositor (primary)
  - **Hyprland** - Dynamic tiling Wayland compositor
  - **GNOME** - Traditional desktop environment
  - **COSMIC** - System76's Rust-based desktop
- **Shell**: Zsh with Oh My Zsh
- **Editors**: Neovim (LazyVim), Zed Editor
- **Terminal**: Ghostty, Kitty, Rio
- **Development Tools**: Claude Code, direnv, devenv, git, lazygit

### Development Environment
- Development tools are declaratively installed via Nix
- Uses devenv and direnv for project-specific development shells
- Neovim configured with LazyVim starter template
- Zed Editor configured with Nix language support

## Configuration Management

### Making Changes
1. Edit relevant `.nix` files:
   - Host-specific: `hosts/<hostname>/`
   - User-specific: `home/<username>/`
   - Shared profiles: `modules/profiles/`
   - User accounts: `modules/users/`
2. Add new files to git (Nix flakes require files to be tracked): `git add <file>`
3. Rebuild system (includes Home Manager):
   - **On blackbox**: `sudo nixos-rebuild switch --flake .#blackbox`
   - **On pero**: `sudo nixos-rebuild switch --flake .#pero`
   - **On vm-aarch64**: `sudo nixos-rebuild switch --flake .#vm-aarch64`
4. Commit changes to git after testing

**Important:** Nix flakes only see files tracked by git, so new files must be added before rebuilding.

### Adding New Hosts
1. Create new directory: `mkdir -p hosts/<hostname>/modules`
2. Create `hosts/<hostname>/default.nix` importing desired profiles
3. Generate hardware config on target machine: `nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix`
4. Add host to `flake.nix` in `nixosConfigurations`
5. Import user accounts from `modules/users/`

### Adding New Users
1. Create user definition in `modules/users/<username>.nix`
2. Create Home Manager config in `home/<username>/`
3. Import user module in host's `default.nix`
4. Add to `home-manager.users` in host config

### Key Configuration Areas
- **System profiles**: `modules/profiles/` (base, desktop, laptop)
- **Host-specific settings**: `hosts/<hostname>/default.nix` and `hosts/<hostname>/modules/`
- **User accounts**: `modules/users/` (reusable across hosts)
- **User packages & configs**: `home/<username>/`
- **Window managers**:
  - Niri config in `home/todor/modules/niri.nix`
  - Hyprland config in `home/todor/modules/hyprland.nix`
  - Desktop services in `modules/profiles/desktop.nix`
- **Shell config**: Zsh and Oh My Zsh setup in user configuration
- **Editor config**: Neovim LazyVim in `home/todor/config/nvim/`
- **iCloud integration**: `home/todor/modules/icloud.nix` - See `docs/ICLOUD-SETUP.md` for setup instructions

### Testing Changes
- Use `nixos-rebuild test` for system changes without permanent switch
- Nix provides build-time validation of configuration syntax
- Generation rollback available if issues occur
- Validate niri config: `niri validate -c ~/.config/niri/config.kdl`

## Window Managers

### Niri (Primary)
Niri is a scrollable-tiling Wayland compositor with a unique horizontal workspace model.

**Configuration Files:**
- **Main config**: `~/.config/niri/config.kdl` (generated from `home/todor/modules/niri.nix`)
- **Waybar config**: `~/.config/waybar/config-niri` (niri-specific)
- **Waybar style**: `~/.config/waybar/style-niri.css`
- **Scripts**: `~/.config/niri/scripts/`
  - `wallpaper.sh` - Wallpaper picker with pywal integration
  - `clipboard.sh` - Clipboard history manager

**Key Features:**
- Horizontal scrolling workspaces
- Column-based tiling layout
- Shared applications and scripts with Hyprland
- Integrated waybar, mako, clipboard management, wallpaper handling

**Startup Applications:**
- Waybar (status bar)
- Mako (notifications)
- swww-daemon (wallpaper)
- Clipboard history watchers
- Blueman & NetworkManager applets
- Ghostty, Brave, Spotify

**Essential Keybindings:**
- `Mod+Return` / `Mod+T` - Terminal (Ghostty)
- `Mod+Q` - Close window
- `Mod+Space` - Application launcher (Wofi)
- `Mod+E` - File manager (Nautilus)
- `Mod+S` - Browser (Brave)
- `Mod+W` - Wallpaper selector
- `Mod+V` - Clipboard history
- `Mod+F` - Fullscreen
- `Mod+1-9` - Switch workspace
- `Mod+Shift+1-9` - Move window to workspace
- `Mod+H/J/K/L` - Focus window (vim-style)
- `Mod+Shift+H/J/K/L` - Move window
- `Mod+Shift+E` - Exit niri

**Screenshots:**
- `Print` - Screenshot
- `Mod+Shift+S` - Screenshot entire screen
- `Mod+Print` - Screenshot window

### Hyprland (Alternative)
Dynamic tiling Wayland compositor with advanced animations and effects.

**Configuration:**
- Main config in `home/todor/modules/hyprland.nix`
- Uses separate waybar config (`~/.config/waybar/config`)
- Shares wofi, scripts, and most applications with niri

**Switching Between Window Managers:**
1. Log out of current session
2. At login screen (GDM/COSMIC greeter), select session:
   - Choose "niri" for niri session
   - Choose "Hyprland" for Hyprland session
3. Log in

Both window managers share:
- Application packages
- Wofi configuration
- Custom scripts (wallpaper, clipboard)
- Theming and fonts
- Terminal and editor configs

## Cloud Services Integration

### iCloud
The system includes integration with Apple iCloud services:
- **Mail, Calendar, Contacts**: Full support via Evolution and GNOME Online Accounts
- **iCloud Drive & Photos**: Limited support (web access only)
- **Configuration**: `home/todor/modules/icloud.nix`
- **Setup Guide**: See `docs/ICLOUD-SETUP.md` for detailed instructions

Quick start:
```bash
# Open GNOME Online Accounts to add iCloud
gnome-control-center online-accounts

# Or launch Evolution directly
evolution
```

**Important**: You must use an app-specific password (not your regular Apple ID password). Generate one at [appleid.apple.com](https://appleid.apple.com) under Security → App-Specific Passwords.