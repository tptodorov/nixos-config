# System Configuration Matrix

This document provides an overview of all configured systems and their profiles.

## NixOS Hosts

| Host | Type | Form Factor | Profiles | Home Manager |
|------|------|-------------|----------|--------------|
| **blackbox** | NixOS | Desktop | base, desktop, apfs, snap, gaming | todor |
| **blade** | NixOS | Laptop | base, desktop, laptop, snap, gaming | todor |
| **vm-aarch64** | NixOS | VM | base, desktop | todor |

## Darwin Hosts

| Host | Type | Form Factor | Home Manager |
|------|------|-------------|--------------|
| **mac** | nix-darwin | Laptop | todor (macOS variant) |

## Standalone Home Manager

| Config | System | Architecture | Use Case |
|--------|--------|--------------|----------|
| **todor** | Non-NixOS (Arch, Ubuntu) | x86_64 | Development on other Linux distros |
| **todor-aarch64** | Non-NixOS | ARM64 | ARM-based systems |

## Profile Reference

### Base Profile (`modules/profiles/base.nix`)
Applied to: **All NixOS hosts**

Core system configuration including:
- Bootloader (systemd-boot)
- Nix settings and garbage collection
- OpenSSH
- NetworkManager
- Avahi (mDNS)
- Essential packages (vim, git, ripgrep, etc.)

### Desktop Profile (`modules/profiles/desktop.nix`)
Applied to: **blackbox, blade, vm-aarch64**

Desktop environment including:
- COSMIC Desktop (default greeter)
- Niri window manager
- MangoWC compositor
- PipeWire audio
- Hardware acceleration
- Flatpak support
- Mac-style keyboard remapping (keyd-mac)

### Laptop Profile (`modules/profiles/laptop.nix`)
Applied to: **blade**

Laptop-specific features:
- TLP power management
- Thermald thermal management
- Lid switch handling
- Touchpad configuration
- Backlight control (light)
- WiFi power saving management

### APFS Profile (`modules/profiles/apfs.nix`)
Applied to: **blackbox**

macOS interoperability:
- APFS filesystem support (for reading Apple partitions)
- Useful when dual-booting with macOS

### Snap Profile (`modules/profiles/snap.nix`)
Applied to: **blackbox, blade**

Snap package manager integration for systems where snap packages are needed.

### Gaming Profile (`modules/profiles/gaming.nix`)
Applied to: **blackbox, blade**

Gaming-related packages and optimizations.

### Form Factor Profile (`modules/profiles/form-factor.nix`)
Applied to: **All NixOS hosts** (auto-determined)

Conditionally applies form-factor-specific settings based on `formFactor` option.

### keyd-mac Profile (`modules/profiles/keyd-mac.nix`)
Auto-imported by: **desktop.nix**

Mac-style keyboard remapping (Cmd+C for copy, etc.) on all desktop systems.

## Quick Reference

### Applying Configuration Changes

```bash
# Test a configuration (no permanent switch)
sudo nixos-rebuild test --flake .#<hostname>

# Apply configuration to current system
sudo nixos-rebuild switch --flake .#<hostname>

# Build without switching
nixos-rebuild build --flake .#<hostname>
```

### Available Hosts
```bash
# NixOS
make blackbox
make blade
make vm

# nix-darwin
make mac

# Standalone Home Manager
make home              # todor (x86_64)
make home-aarch64      # todor-aarch64
```

## Adding a New Host

1. Create directory: `mkdir -p hosts/<hostname>/modules`
2. Add `hosts/<hostname>/default.nix`:
   ```nix
   {
     inputs,
     outputs,
     ...
   }:
   {
     imports = [
       ./hardware-configuration.nix
       inputs.home-manager.nixosModules.home-manager
       inputs.niri.nixosModules.niri
       
       # Profiles
       ../../modules/profiles/base.nix
       # ... other profiles ...
       
       # User
       ../../modules/users/todor.nix
       ../../modules/common/fonts.nix
     ];

     home-manager = {
       backupFileExtension = "backup";
       extraSpecialArgs = {
         inherit inputs outputs;
         laptop = false;  # Set to true for laptops
         standalone = false;
       };
       sharedModules = [
         inputs.nixvim.homeModules.nixvim
       ];
       users.todor = ../../home/todor;
     };

     system.stateVersion = "25.11";
   }
   ```

3. Generate hardware config on target machine:
   ```bash
   nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
   ```

4. Add to `flake.nix` nixosConfigurations:
   ```nix
   <hostname> = nixpkgs.lib.nixosSystem {
     specialArgs = {
       inherit inputs outputs;
       laptop = false;  # Set to true if laptop
       standalone = false;
     };
     modules = [
       # ... standard imports ...
       ./hosts/<hostname>
     ];
   };
   ```

5. Add to Makefile shortcuts:
   ```makefile
   <hostname>:
   	$(MAKE) switch NIXNAME=<hostname>
   ```

6. Test and commit:
   ```bash
   sudo nixos-rebuild test --flake .#<hostname>
   git add . && git commit -m "Add <hostname> configuration"
   ```
