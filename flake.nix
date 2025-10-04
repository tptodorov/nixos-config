{
  description = ''
    Flake for configuring linux instances
  '';

  inputs = {
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
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      fenix,
      home-manager,
      nixpkgs,
      nixvim,
      sops-nix,
      flake-utils,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      lib = import ./lib { inherit inputs; };
    in
    {
      overlays = import ./overlays { inherit inputs; };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            alejandra
            deadnix
            statix
            lazygit
          ];
        };
      }
    )
    // {
      nixosConfigurations = {
        blackbox = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            ./hosts/blackbox
          ];

        };
      };
    };
}
