# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a NixOS system configuration repository using Nix Flakes for declarative system and user environment management. It manages both system-level configuration for the "blackbox" host and user-level configuration for user "todor" via Home Manager.

## Common Commands

### System Management
```bash
# Rebuild and switch NixOS system configuration
sudo nixos-rebuild switch --flake .#blackbox

# Test system configuration without switching
sudo nixos-rebuild test --flake .#blackbox

# Rebuild user environment with Home Manager
home-manager switch --flake .

# Update flake inputs
nix flake update

# Check flake configuration
nix flake check
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
- **`flake.nix`**: Main flake configuration defining inputs and outputs
- **`hosts/blackbox/`**: Host-specific NixOS system configuration
  - `default.nix`: System packages, services, and settings
  - `hardware-configuration.nix`: Hardware-specific configuration
  - `modules/desktop.nix`: Desktop environment configuration (GNOME, COSMIC, Hyprland, Niri)
  - `modules/`: Other system modules (boot, networking, services, nix)
- **`home/todor/`**: User-specific Home Manager configuration
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
1. Edit relevant `.nix` files in `hosts/blackbox/` or `home/todor/`
2. Add new files to git (Nix flakes require files to be tracked): `git add <file>`
3. Rebuild system (includes Home Manager): `sudo nixos-rebuild switch --flake .#blackbox`
   - Note: Home Manager is integrated into NixOS config, so one rebuild applies both system and user changes
4. Commit changes to git after testing

**Important:** Nix flakes only see files tracked by git, so new files must be added before rebuilding.

### Key Configuration Areas
- **System packages**: `hosts/blackbox/default.nix`
- **User packages**: `home/todor/default.nix`
- **Window managers**:
  - Niri config in `home/todor/modules/niri.nix`
  - Hyprland config in `home/todor/modules/hyprland.nix`
  - Desktop services in `hosts/blackbox/modules/desktop.nix`
- **Shell config**: Zsh and Oh My Zsh setup in user configuration
- **Editor config**: Neovim LazyVim in `home/todor/config/nvim/`

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