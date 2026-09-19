{
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../../modules/common/fonts.nix
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
  ];

  # nix is already installed
  nix.enable = false;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # The user options like homebrew/defaults previously applied to the user
  # running darwin-rebuild now attach to explicitly.
  system.primaryUser = "todor.todorov";

  homebrew.enable = true;
  system.tools.darwin-rebuild.enable = true;

  # Home Manager owns interactive zsh completion setup with a cached compinit.
  programs.zsh = {
    enable = true;
    enableGlobalCompInit = false;
    enableBashCompletion = false;
  };

  # reduce distrations
  system.startup.chime = false;

}
