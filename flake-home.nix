{
  description = "Standalone Home Manager configuration for todor user";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [];
        };
      };
    in
    {
      homeConfigurations = {
        # Standalone home-manager configuration for non-NixOS systems
        todor = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [
            {
              home = {
                username = "todor";
                homeDirectory = "/home/todor";
                stateVersion = "24.05";
              };

              # Enable Home Manager to manage itself
              programs.home-manager.enable = true;

              # Import the existing home configuration
              imports = [
                ./home/todor/default.nix
              ];

              # Override any NixOS-specific settings that won't work on non-NixOS
              # Disable systemd user services that might conflict
              systemd.user.startServices = "sd-switch";
            }
          ];

          extraSpecialArgs = {
            inherit inputs;
          };
        };
      };

      # Also provide aarch64 support for ARM machines
      homeConfigurations.todor-aarch64 = home-manager.lib.homeManagerConfiguration {
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
              stateVersion = "24.05";
            };

            programs.home-manager.enable = true;

            imports = [
              ./home/todor/default.nix
            ];

            systemd.user.startServices = "sd-switch";
          }
        ];

        extraSpecialArgs = {
          inherit inputs;
        };
      };
    };
}
