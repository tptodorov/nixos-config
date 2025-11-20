# NixOS System Configuration

Declarative system configuration for my personal machines using **NixOS** and **Nix Flakes**.

## 🚀 Quick Start

### Bootstrap New Machine
```bash
# 1. Clone
git clone https://github.com/tptodorov/nixos-config ~/nix-config && cd ~/nix-config

# 2. Generate Hardware Config
mkdir -p hosts/<hostname>
nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix

# 3. Create Host Config (hosts/<hostname>/default.nix) & Add to flake.nix

# 4. Install
sudo nixos-rebuild switch --flake .#<hostname>
```

### Standalone Home Manager (macOS/Ubuntu)

For non-NixOS systems (macOS, Ubuntu, Arch, etc.):

```bash
# 1. Install Nix
sh <(curl -L https://nixos.org/nix/install) --daemon
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# 2. Clone
git clone https://github.com/tptodorov/nixos-config ~/nix-config && cd ~/nix-config

# 3. Install Home Manager (x86_64)
nix run home-manager/master -- switch --flake .#todor -b backup

# 3b. Install Home Manager (ARM64/Apple Silicon)
nix run home-manager/master -- switch --flake .#todor-aarch64 -b backup
```

See [Omarchy Setup](docs/OMARCHY-SETUP.md) for more details.

## 🛠 Common Workflows

```bash
# Apply Changes (NixOS)
sudo nixos-rebuild switch --flake .#<hostname>

# Apply Changes (Home Manager)
home-manager switch --flake .#todor

# Update Flake Inputs
nix flake update
```

## ⌨️ Keybindings & Features

- **Window Manager**: `Super` (Cmd/Win) is the main modifier.
    - `Super+Return`: Terminal
    - `Super+Space`: Launcher
    - `Super+Q`: Close Window
    - `Super+V`: Clipboard History (Searchable text/images)
- **Mac-Style**: `Alt` and `Super` swapped on desktop profiles (`Cmd+C/V` works).

## 🌐 Browser & Sync (Brave)
- **Sync**: Open `brave://settings/braveSync` (or alias `brave-sync`).
- **Login**: Use `todor@peychev.com`.
- **Select**: Sync everything (Bookmarks, Passwords, Extensions, etc.).

## 📚 Documentation
- [Secrets Management](docs/SECRETS-SETUP.md)
- [Multi-Host Setup](docs/MULTI-HOST-SETUP.md)
- [iCloud Integration](docs/ICLOUD-SETUP.md)
- [MacBook Suspend Fix](docs/MACBOOK-SUSPEND-FIX.md)
