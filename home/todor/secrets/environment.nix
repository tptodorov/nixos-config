{ config, lib, pkgs, ... }:
{
  # Environment variables and secrets for user todor's zsh profile
  # This file contains non-sensitive defaults for user todor
  # Override with local.nix for actual secrets

  home.sessionVariables = {
    # Default values for todor - override these in local.nix
    # Example secrets that might be needed:
    # GITHUB_TOKEN = "your-github-token";
    # AWS_ACCESS_KEY_ID = "your-aws-key";
    # AWS_SECRET_ACCESS_KEY = "your-aws-secret";
    # OPENAI_API_KEY = "your-openai-key";
    # ANTHROPIC_API_KEY = "your-anthropic-key";
    # OPENROUTER_API_KEY = "your-openrouter-key";

    # Non-sensitive environment variables for todor
    BROWSER = "firefox";
    TERMINAL = "ghostty";

    # User-specific preferences
    EDITOR = "nvim";
    PAGER = "less";
  };

  # Zsh-specific environment setup
  programs.zsh = {
    sessionVariables = {
      # Additional zsh-specific variables
      HISTSIZE = "10000";
      SAVEHIST = "10000";
    };

    # Shell aliases that might use secrets
    shellAliases = {
      # Examples of aliases that might need secrets
      # "deploy" = "cd ~/projects && ./deploy.sh";
      # "backup" = "rclone sync ~/Documents remote:backup";
    };

    # Custom shell functions that might use environment variables
    initContent = ''
      # Custom zsh functions can access environment variables here
      # Example:
      # function git-clone-private() {
      #   git clone "https://$GITHUB_TOKEN@github.com/$1.git"
      # }
    '';
  };
}