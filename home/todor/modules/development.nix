{ config, lib, pkgs, ... }:
{
  # Development tools and environment
  home.packages = with pkgs; [
    devenv
  ];

  programs = {
    # Version control
    git = {
      enable = true;
      userName = "Todor Todorov";
      userEmail = "98095+tptodorov@users.noreply.github.com";
    };

    gh = {
      enable = true;
      gitCredentialHelper.enable = true;
      hosts = {
        "github.com" = {
          user = "tptodorov";
        };
      };
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
        aliases = {
          co = "pr checkout";
          pv = "pr view";
        };
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui.theme = {
          lightTheme = true;
          activeBorderColor = [ "blue" "bold" ];
          inactiveBorderColor = [ "black" ];
          selectedLineBgColor = [ "default" ];
        };
      };
    };

    # Development environment
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };

    # Editors
    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython3 = true;
    };

    zed-editor = {
      enable = true;
      package = pkgs.zed-editor;
      extraPackages = [ pkgs.nixd ];
      extensions = [
        "nix"
        "tokyo-night"
        "php"
      ];
      userSettings = builtins.fromJSON (builtins.readFile ../config/zed/private_settings.json);
    };

    claude-code.enable = true;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}