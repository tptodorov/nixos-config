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
- **`home/todor/`**: User-specific Home Manager configuration
  - `default.nix`: User packages, dotfiles, and application configs
  - `config/`: Application-specific configuration files

### Technology Stack
- **OS**: NixOS 25.05
- **Package Manager**: Nix with Flakes
- **Desktop**: Hyprland (Wayland) with GNOME fallback
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
2. For system changes: `sudo nixos-rebuild switch --flake .#blackbox`
3. For user changes: `home-manager switch --flake .`
4. Commit changes to git after testing

### Key Configuration Areas
- **System packages**: `hosts/blackbox/default.nix`
- **User packages**: `home/todor/default.nix`
- **Desktop environment**: Hyprland config in `home/todor/config/hypr/`
- **Shell config**: Zsh and Oh My Zsh setup in user configuration
- **Editor config**: Neovim LazyVim in `home/todor/config/nvim/`

### Testing Changes
- Use `nixos-rebuild test` for system changes without permanent switch
- Nix provides build-time validation of configuration syntax
- Generation rollback available if issues occur