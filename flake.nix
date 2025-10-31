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
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    {
      self,
      fenix,
      home-manager,
      nixpkgs,
      nixvim,
      sops-nix,
      ...
    }@inputs:
    let
      inherit (self) outputs;

    in
    {
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {
        blackbox = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            ./hosts/blackbox
          ];

        };
        vm-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          vm = true;
          specialArgs = { inherit inputs outputs; };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            ./hosts/vm-aarch64
          ];
        };

      };
    };

}
