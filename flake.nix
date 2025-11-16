{
  description = ''
    Flake for configuring linux instances
  '';

  inputs = {
    # Other packages
    jujutsu.url = "github:martinvonz/jj";
    zig.url = "github:mitchellh/zig-overlay";

    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs =
    {
      self,
      fenix,
      home-manager,
      nixos-hardware,
      nixpkgs,
      nixvim,
      sops-nix,
      dms,
      dgop,
      ...
    }@inputs:
    let
      inherit (self) outputs;

    in
    {
      nixosConfigurations = {
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
    };

}
