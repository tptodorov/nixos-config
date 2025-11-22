# Home Manager configuration for user todor
{
  ...
}:
{
  imports = [
    # User modules
    ./modules/development.nix
    ./modules/shell.nix
    ./modules/terminal.nix
    ./secrets/secrets.nix
  ];

  # Nixpkgs configuration
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };
  # Home Manager version
  home.stateVersion = "25.05";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

}
