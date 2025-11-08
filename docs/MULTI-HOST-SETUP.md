# Multi-Host NixOS Configuration Guide

This repository now supports multiple NixOS hosts with shared, reusable configuration profiles.

## Repository Structure

### Configuration Profiles (Reusable)

Located in `modules/profiles/`:

- **`base.nix`**: Core system configuration for all hosts
  - Nix flakes and settings
  - Garbage collection and optimization
  - SSH, mDNS (Avahi)
  - Essential packages (vim, git, wget, etc.)

- **`desktop.nix`**: Full desktop environment
  - GNOME, COSMIC desktop environments
  - Hyprland, Niri window managers
  - Hardware acceleration
  - Rust toolchain (for COSMIC)

- **`laptop.nix`**: Laptop-specific optimizations
  - TLP power management
  - Thermal management (thermald)
  - Lid switch handling
  - Touchpad configuration
  - Battery optimization

### Current Hosts

1. **blackbox** - Desktop workstation
   - Profiles: `base.nix` + `desktop.nix`
   - Custom USB gadget networking
   - Full desktop environment

2. **pero** - MacBook Pro 13" 2017
   - Profiles: `base.nix` + `desktop.nix` + `laptop.nix`
   - Apple hardware optimizations
   - Retina display scaling
   - Power management
   - See `docs/PERO-SETUP.md` for installation guide

3. **vm-aarch64** - ARM64 virtual machine
   - Custom VM configuration

### User Accounts

All user accounts are defined in `modules/users/` and can be imported by any host:

- **todor**: Main user account
  - Default password: `todor` (change after first login!)
  - Member of: wheel, networkmanager
  - Shell: zsh
  - Passwordless sudo enabled

Home Manager configurations are in `home/<username>/`.

## Adding a New Host

### Quick Start

```bash
# 1. Create host directory
mkdir -p hosts/<hostname>/modules

# 2. Create default.nix
cat > hosts/<hostname>/default.nix <<EOF
{
  inputs,
  outputs,
  pkgs,
  vm ? false,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.home-manager

    # Choose profiles based on machine type:
    ../../modules/profiles/base.nix
    # ../../modules/profiles/desktop.nix  # For desktop/laptop
    # ../../modules/profiles/laptop.nix   # For laptops only

    # Import users
    ../../modules/users/todor.nix

    # Shared modules
    ../../modules/common/fonts.nix
    ../../secrets/ssh-keys.nix
  ];

  # Set hostname
  networking.hostName = "<hostname>";

  # Home Manager configuration
  home-manager = {
    backupFileExtension = "backup";
    extraSpecialArgs = { inherit inputs outputs vm; };
    sharedModules = [
      inputs.nixvim.homeModules.nixvim
    ];
    users.todor = ../../home/todor;
  };

  # System version
  system.stateVersion = "25.05";
}
EOF

# 3. Generate hardware configuration on target machine
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 4. Add to flake.nix
# Edit flake.nix and add to nixosConfigurations:
#   <hostname> = nixpkgs.lib.nixosSystem {
#     specialArgs = { inherit inputs outputs; vm = false; };
#     modules = [
#       inputs.home-manager.nixosModules.home-manager
#       ./hosts/<hostname>
#     ];
#   };

# 5. Add to git and test
git add hosts/<hostname>/
nixos-rebuild build --flake .#<hostname>
```

## Adding a New User

### Quick Start

```bash
# 1. Create user definition
cat > modules/users/<username>.nix <<EOF
{ config, pkgs, lib, ... }:
{
  users.users.<username> = {
    isNormalUser = true;
    description = "Full Name";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [];
    shell = pkgs.zsh;
    initialPassword = "<username>";
  };

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
EOF

# 2. Create Home Manager configuration
mkdir -p home/<username>
cat > home/<username>/default.nix <<EOF
{ config, lib, vm ? false, ... }:
{
  imports = [
    # Import desired user modules
  ];

  nixpkgs.config = {
    allowUnfree = true;
  };

  home.username = lib.mkDefault "<username>";
  home.homeDirectory = lib.mkDefault "/home/\${config.home.username}";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
EOF

# 3. Import in host configuration
# Add to hosts/<hostname>/default.nix:
#   imports = [
#     ...
#     ../../modules/users/<username>.nix
#   ];
#
#   home-manager.users.<username> = ../../home/<username>;

# 4. Rebuild
git add modules/users/<username>.nix home/<username>/
sudo nixos-rebuild switch --flake .#<hostname>
```

## Profile Customization

### Disabling Features from Profiles

Use `lib.mkForce` to override profile defaults:

```nix
# In hosts/<hostname>/default.nix
{
  # Disable a desktop environment from desktop.nix
  services.desktopManager.cosmic.enable = lib.mkForce false;

  # Override laptop power management
  services.tlp.enable = lib.mkForce false;
}
```

### Extending Profiles

Add host-specific modules alongside profiles:

```nix
{
  imports = [
    ../../modules/profiles/base.nix
    ../../modules/profiles/laptop.nix
    ./modules/nvidia.nix  # Host-specific module
  ];
}
```

## Building and Testing

```bash
# Build without switching
nixos-rebuild build --flake .#<hostname>

# Test without making permanent
sudo nixos-rebuild test --flake .#<hostname>

# Build and switch
sudo nixos-rebuild switch --flake .#<hostname>

# Check all configurations
nix flake check
```

## Migration Checklist

When migrating an existing NixOS system to this structure:

- [ ] Back up `/etc/nixos/configuration.nix` and `/etc/nixos/hardware-configuration.nix`
- [ ] Create new host directory: `hosts/<hostname>/`
- [ ] Copy hardware-configuration.nix to host directory
- [ ] Create default.nix importing appropriate profiles
- [ ] Add host to flake.nix
- [ ] Build configuration: `nixos-rebuild build --flake .#<hostname>`
- [ ] Test configuration: `sudo nixos-rebuild test --flake .#<hostname>`
- [ ] Switch to new config: `sudo nixos-rebuild switch --flake .#<hostname>`
- [ ] Verify all services and applications work
- [ ] Commit changes to git

## Best Practices

1. **Always test builds** before switching: `nixos-rebuild build --flake .#<hostname>`
2. **Keep git clean**: Only committed files are visible to Nix flakes
3. **Use profiles wisely**: Don't duplicate configuration across hosts
4. **Document host-specific quirks**: Add README.md in `hosts/<hostname>/` for unusual hardware
5. **Version control everything**: Commit after successful builds
6. **Test on one host first**: When modifying profiles, test on one host before deploying to all

## Troubleshooting

### "attribute already defined" errors

Profile modules may conflict with host-specific settings. Use `lib.mkDefault` in profiles and `lib.mkForce` in hosts.

### Flake doesn't see new files

Run `git add <file>` before building. Nix flakes only see tracked files.

### Hardware-specific issues

Check `hardware-configuration.nix` was generated correctly with `nixos-generate-config`.

### Build takes forever

First build downloads and compiles everything. Subsequent builds are much faster. Use `--option substituters https://cache.nixos.org` to use binary cache.
