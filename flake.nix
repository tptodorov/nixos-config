{
  description = "NixOS and Home Manager configuration for todor";

  inputs = {
    # ============================================
    # Core System Inputs
    # ============================================

    # nixpkgs: The main NixOS package repository
    # - Contains all system packages and NixOS modules
    # - Used by: All hosts (blackbox, pero, blade), standalone home-manager configs, darwin
    # - Version: nixpkgs-25.11-darwin stable release branch (compatible with both NixOS and macOS)
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";

    # nixos-hardware: Hardware-specific NixOS configurations
    # - Provides optimized settings for specific hardware (laptops, GPUs, etc.)
    # - Used by: hosts/pero (MacBook Pro), can be used by other hosts for hardware quirks
    # - Version: master branch (latest hardware support)
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # home-manager: Declarative user environment management
    # - Manages user packages, dotfiles, and application configurations
    # - Used by: All NixOS hosts (integrated), standalone configs (todor, todor-aarch64)
    # - Version: release-25.11 stable branch (matches nixpkgs)
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ============================================
    # Development Tools
    # ============================================

    # jujutsu: Next-generation version control system (alternative to Git)
    # - Provides the `jj` command for version control
    # - Used by: User environment (home/todor/default.nix)
    # - Version: main branch (latest features)
    jujutsu.url = "github:martinvonz/jj";

    # zig: Zig programming language overlay
    # - Provides latest Zig compiler and toolchain
    # - Used by: All NixOS hosts via overlay (blackbox, pero, blade)
    # - Version: main branch (latest Zig releases)
    zig.url = "github:mitchellh/zig-overlay";

    # fenix: Rust toolchain manager for Nix
    # - Provides up-to-date Rust compiler, cargo, clippy, rust-analyzer
    # - Used by: Desktop profile (modules/profiles/desktop.nix) for COSMIC and Rust development
    # - Provides: Complete Rust toolchain with all components
    # - Version: main branch (latest Rust releases)
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim: NixOS module for configuring Neovim declaratively
    # - Provides Neovim configuration as Nix modules
    # - Used by: Home manager config (home/todor/modules/nixvim.nix)
    # - Version: nixos-25.11 stable branch (matches system)
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # sops-nix: Secrets management using SOPS (Secrets OPerationS)
    # - Encrypts secrets in git, decrypts them at build/runtime
    # - Used by: System configuration (for API keys, passwords, etc.)
    # - Version: main branch
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ============================================
    # Package Managers
    # ============================================

    # nix-snapd: Snap package manager integration for NixOS
    # - Enables installing snap packages alongside Nix packages
    # - Used by: System configuration (optional per-host)
    # - Provides: snapd service and snap CLI tool
    # - Version: main branch
    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ============================================
    # Window Managers and Desktop Environment
    # ============================================

    # niri: Scrollable-tiling Wayland compositor
    # - Primary window manager with horizontal workspace model
    # - Used by: Desktop profile (modules/profiles/desktop.nix), Home manager (home/todor/modules/niri.nix)
    # - Provides: niri-unstable package, NixOS module, Home Manager module
    # - Version: main branch (latest niri features)
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dms: Dank Material Shell (GNOME Shell extension)
    # - Material Design-inspired GNOME Shell theme and layout
    # - Used by: Can be enabled in GNOME desktop environment
    # - Depends on: dgop (Dank GNOME Overlay Package)
    # - Version: main branch
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dgop: Dank GNOME Overlay Package
    # - Dependency for DankMaterialShell
    # - Provides GNOME-related packages and overlays
    # - Used by: dms input (required dependency)
    # - Version: main branch
    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ============================================
    # macOS Support
    # ============================================

    # nix-darwin: NixOS-like system configuration for macOS
    # - Enables declarative macOS system management (similar to NixOS)
    # - Used by: Darwin host configuration (hosts/mac, for work MacBook)
    # - Version: nix-darwin-25.11 branch (matches nixpkgs-25.11-darwin)
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    disko.url = "github:nix-community/disko/latest";
    disko.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      nixvim,
      sops-nix,
      nix-snapd,
      fenix,
      zig,
      niri,
      dms,
      dgop,
      jujutsu,
      nix-darwin,
      disko,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      # ============================================
      # NixOS Configurations (Full System)
      # ============================================
      nixosConfigurations = {
        # Desktop workstation
        blackbox = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
          };
          modules = [
            {
              nixpkgs.overlays = [
                inputs.zig.overlays.default
                inputs.niri.overlays.niri
              ];
            }
            inputs.home-manager.nixosModules.home-manager
            ./hosts/blackbox
          ];
        };

        # Laptop for development, business, and personal work
        blade = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs outputs;
            laptop = true;
            standalone = false;
          };
          modules = [
            {
              nixpkgs.overlays = [
                inputs.zig.overlays.default
                inputs.niri.overlays.niri
              ];
            }
            inputs.home-manager.nixosModules.home-manager
            ./hosts/blade
          ];
        };
      };

      # ============================================
      # Standalone Home Manager Configurations
      # (For non-NixOS systems like Arch, Ubuntu, etc.)
      # ============================================
      homeConfigurations = {
        # Standalone home-manager for x86_64 systems (e.g., Arch Linux)
        todor = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;

          modules = [
            {
              home = {
                username = "todor";
                homeDirectory = "/home/todor";
                stateVersion = "25.05";
              };

              # Enable Home Manager to manage itself
              programs.home-manager.enable = true;

              # Import the existing home configuration
              imports = [
                inputs.niri.homeModules.niri
                inputs.nixvim.homeModules.nixvim
                inputs.cosmic-manager.homeManagerModules.cosmic-manager
                ./home/todor/default.nix
              ];

              # Override any NixOS-specific settings that won't work on non-NixOS
              systemd.user.startServices = "sd-switch";
            }
          ];

          extraSpecialArgs = {
            inherit inputs;
            laptop = false; # Not a laptop (change to true if on laptop)
            standalone = true; # Standalone Home Manager (protect certain files)
          };
        };

        # Standalone home-manager for ARM64 systems
        todor-aarch64 = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "aarch64-linux";
            config = {
              allowUnfree = true;
              permittedInsecurePackages = [ ];
            };
          };

          modules = [
            {
              home = {
                username = "todor";
                homeDirectory = "/home/todor";
                stateVersion = "25.05";
              };

              programs.home-manager.enable = true;

              imports = [
                inputs.niri.homeModules.niri
                inputs.nixvim.homeModules.nixvim
                inputs.cosmic-manager.homeManagerModules.cosmic-manager
                ./home/todor/default.nix
              ];

              systemd.user.startServices = "sd-switch";
            }
          ];

          extraSpecialArgs = {
            inherit inputs;
            laptop = false; # Not a laptop (change to true if on ARM laptop)
            standalone = true; # Standalone Home Manager (protect certain files)
          };
        };
      };

      darwinConfigurations = {
        # my redis mac book pro
        "DR94XJ1435-Todor-Peychev-Todorov" = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/mac
            {
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = {
                inherit inputs;
                laptop = true; # MacBook Pro is a laptop
              };
              home-manager.users."todor.todorov" = import ./home/todor/mac.nix;
              home-manager.backupFileExtension = "bak";
              users.users."todor.todorov" = {
                name = "todor.todorov";
                home = "/Users/todor.todorov";
              };
            }
          ];
          specialArgs = {
            inherit inputs;
          };
        };
      };

    };
}
