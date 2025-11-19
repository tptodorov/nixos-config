{
  description = "NixOS and Home Manager configuration for todor";

  inputs = {
    # Core
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools
    jujutsu.url = "github:martinvonz/jj";
    zig.url = "github:mitchellh/zig-overlay";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Window managers and desktop
    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.dgop.follows = "dgop";
    };

    dgop = {
      url = "github:AvengeMedia/dgop";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    nixvim,
    sops-nix,
    fenix,
    zig,
    niri,
    dms,
    dgop,
    jujutsu,
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
          vm = false;
        };
        modules = [
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                inputs.zig.overlays.default
                inputs.niri.overlays.niri
              ];
            }
          )
          inputs.home-manager.nixosModules.home-manager
          ./hosts/blackbox
        ];
      };

      # MacBook Pro 13" 2017
      pero = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          vm = false;
        };
        modules = [
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                inputs.zig.overlays.default
                inputs.niri.overlays.niri
              ];
            }
          )
          inputs.home-manager.nixosModules.home-manager
          ./hosts/pero
        ];
      };

      # ARM64 VM
      vm-aarch64 = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = {
          inherit inputs outputs;
          vm = true;
        };
        modules = [
          (
            { pkgs, ... }:
            {
              nixpkgs.overlays = [
                inputs.zig.overlays.default
                inputs.niri.overlays.niri
              ];
            }
          )
          inputs.home-manager.nixosModules.home-manager
          ./hosts/vm-aarch64
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
              inputs.nixvim.homeManagerModules.nixvim
              ./home/todor/default.nix
            ];


            # Override any NixOS-specific settings that won't work on non-NixOS
            systemd.user.startServices = "sd-switch";
          }
        ];

        extraSpecialArgs = {
          inherit inputs;
          vm = false;  # Not a VM, full desktop features
          laptop = false;  # Not a laptop (change to true if on laptop)
          standalone = true;  # Standalone Home Manager (protect certain files)
        };
      };

      # Standalone home-manager for ARM64 systems
      todor-aarch64 = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-linux";
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [];
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
              inputs.nixvim.homeManagerModules.nixvim
              ./home/todor/default.nix
            ];


            systemd.user.startServices = "sd-switch";
          }
        ];

        extraSpecialArgs = {
          inherit inputs;
          vm = false;  # Not a VM, full desktop features
          laptop = false;  # Not a laptop (change to true if on ARM laptop)
          standalone = true;  # Standalone Home Manager (protect certain files)
        };
      };
    };
  };
}
