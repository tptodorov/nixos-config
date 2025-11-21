# Configuration Examples

## Adding Another User with Secrets

Here's how to add user-specific secrets for a new user (e.g., `alice`):

### 1. Create User Directory Structure

```bash
mkdir -p home/alice/{modules,secrets,config}
```

### 2. Create User Configuration

```nix
# home/alice/default.nix
{ config, lib, pkgs, ... }:
{
  imports = [
    ./modules/terminal.nix
    ./modules/development.nix
    # Add other modules as needed
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (_: true);
  };

  home.username = lib.mkDefault "alice";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
```

### 3. Create Alice's Terminal Module

```nix
# home/alice/modules/terminal.nix
{ config, lib, pkgs, ... }:
{
  imports = [
    # Import alice's user-specific secrets
  ] ++ lib.optionals (builtins.pathExists ../secrets/local.nix) [
    ../secrets/local.nix
  ];

  programs = {
    zsh = {
      enable = true;
      oh-my-zsh.enable = true;
    };
    # Other programs...
  };
}
```

### 4. Create Alice's Secrets Configuration

```bash
# Copy templates
cp home/todor/secrets/local.nix.example home/alice/secrets/
```

### 5. Customize Alice's Environment

```nix
# home/alice/secrets/environment.nix
{ config, lib, pkgs, ... }:
{
  home.sessionVariables = {
    # Alice's preferences (different from todor)
    BROWSER = "chromium";
    TERMINAL = "kitty";
    EDITOR = "code";
  };

  programs.zsh = {
    shellAliases = {
      # Alice's custom aliases
      "ll" = "ls -la";
      "grep" = "rg";
    };
  };
}
```

### 6. Add Alice to NixOS Configuration

```nix
# modules/users/alice.nix
{ config, pkgs, lib, ... }:
{
  users.users.alice = {
    isNormalUser = true;
    description = "Alice Smith";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };
}
```

### 7. Update Main Host Configuration

```nix
# hosts/blackbox/default.nix
{
  imports = [
    # ... existing imports ...
    ../../modules/users/alice.nix
  ];

  home-manager = {
    users = {
      todor = ../../home/todor;
      alice = ../../home/alice;  # Add alice
    };
  };
}
```

## User-Specific Secrets Examples

### Todor (Developer)
```nix
# home/todor/secrets/local.nix
{
  home.sessionVariables = {
    GITHUB_TOKEN = "ghp_developer_token";
    OPENAI_API_KEY = "sk-dev-key";
    AWS_PROFILE = "development";
  };
}
```

### Alice (Data Scientist)
```nix
# home/alice/secrets/local.nix
{
  home.sessionVariables = {
    GITHUB_TOKEN = "ghp_alice_token";
    JUPYTER_TOKEN = "jupyter-secret";
    KAGGLE_USERNAME = "alice_kaggle";
    KAGGLE_KEY = "kaggle-api-key";
  };
}
```

This approach ensures each user has:
- ✅ Isolated secrets and environment variables
- ✅ Custom shell configuration
- ✅ Personal development tools and preferences
- ✅ Secure secret management per user
