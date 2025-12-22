{
  description = "NixOS and Home Manager configuration for todor";

  inputs = {
    # Core - using stable release branches
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Development tools - using main/master branches (pinned via flake.lock)
    jujutsu.url = "github:martinvonz/jj";
    zig.url = "github:mitchellh/zig-overlay";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Window managers and desktop - using main branches (pinned via flake.lock)
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

    # Mac darwin - using main branch
    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    {
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
      nix-darwin,
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

        # MacBook Pro 13" 2017
        pero = nixpkgs.lib.nixosSystem {
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
            ./hosts/pero
          ];
        };

        # Laptop for development, business, and personal work
        blade = nixpkgs.lib.nixosSystem {
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
              home-manager.extraSpecialArgs = { inherit inputs; };
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
