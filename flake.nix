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
        vm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs outputs; };
          modules = [
            inputs.home-manager.nixosModules.home-manager
            ./hosts/vm
          ];
        };

      };
      packages.aarch64-linux.vm-image = self.nixosConfigurations.vm.config.system.build.vm;
    };
}

# To build the VM image for UTM, run the following command:
# nix build .#vm-image
#
# If you get an error about the attribute not being found, it might be because
# you are on a different system than the target system (aarch64-linux).
# In that case, you can try to specify the target system explicitly:
# nix build .#packages.aarch64-linux.vm-image
#
# The resulting image will be in the `result` directory.
