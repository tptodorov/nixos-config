{
  config,
  lib,
  inputs,
  ...
}:
{
  # Encrypted secrets management using sops-nix
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  # sops configuration
  sops = {
    defaultSopsFile = ./secrets.yaml;
    defaultSopsFormat = "yaml";

    # Age key file location
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # Define secrets to be decrypted
    secrets = {
      # GitHub token
      github_token = {
        path = "${config.home.homeDirectory}/.secrets/github_token";
      };

      # OpenAI API key
      openai_api_key = {
        path = "${config.home.homeDirectory}/.secrets/openai_api_key";
      };

      # Anthropic API key
      anthropic_api_key = {
        path = "${config.home.homeDirectory}/.secrets/anthropic_api_key";
      };

      # OpenRouter API key
      openrouter_api_key = {
        path = "${config.home.homeDirectory}/.secrets/openrouter_api_key";
      };

      # AWS credentials
      aws_access_key_id = {
        path = "${config.home.homeDirectory}/.secrets/aws_access_key_id";
      };

      aws_secret_access_key = {
        path = "${config.home.homeDirectory}/.secrets/aws_secret_access_key";
      };

      # Docker Hub token
      docker_hub_token = {
        path = "${config.home.homeDirectory}/.secrets/docker_hub_token";
      };

      # Telegram bot token
      telegram_bot_token = {
        path = "${config.home.homeDirectory}/.secrets/telegram_bot_token";
      };
    };
  };

  # Load secrets into environment variables via zsh
  programs.zsh.initContent = lib.mkAfter ''
    # Load encrypted secrets into environment variables

    # Function to safely load secret
    load_secret() {
      local secret_file="$1"
      local var_name="$2"

      if [[ -r "$secret_file" ]]; then
        export "$var_name"="$(cat "$secret_file")"
      fi
    }

    # Load all secrets
    load_secret "${config.sops.secrets.github_token.path}" "GITHUB_TOKEN"
    load_secret "${config.sops.secrets.openai_api_key.path}" "OPENAI_API_KEY"
    load_secret "${config.sops.secrets.anthropic_api_key.path}" "ANTHROPIC_API_KEY"
    load_secret "${config.sops.secrets.openrouter_api_key.path}" "OPENROUTER_API_KEY"
    load_secret "${config.sops.secrets.aws_access_key_id.path}" "AWS_ACCESS_KEY_ID"
    load_secret "${config.sops.secrets.aws_secret_access_key.path}" "AWS_SECRET_ACCESS_KEY"
    load_secret "${config.sops.secrets.docker_hub_token.path}" "DOCKER_HUB_TOKEN"
    load_secret "${config.sops.secrets.telegram_bot_token.path}" "TELEGRAM_BOT_TOKEN"

    # Alias for tools that expect GITHUB_PERSONAL_ACCESS_TOKEN
    export GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_TOKEN"

    # AWS region (non-secret)
    export AWS_DEFAULT_REGION="us-east-1"

    # Custom functions using secrets
    function git-clone-private() {
      if [[ -z "$GITHUB_TOKEN" ]]; then
        echo "GitHub token not available"
        return 1
      fi
      git clone "https://$GITHUB_TOKEN@github.com/$1.git"
    }

    function docker-login() {
      if [[ -z "$DOCKER_HUB_TOKEN" ]]; then
        echo "Docker Hub token not available"
        return 1
      fi
      echo "$DOCKER_HUB_TOKEN" | docker login --username your-username --password-stdin
    }

    function ai-chat() {
      if [[ -z "$OPENAI_API_KEY" ]]; then
        echo "OpenAI API key not available"
        return 1
      fi
      # Your AI chat logic here
      echo "AI chat ready with OpenAI"
    }

    function deploy-aws() {
      if [[ -z "$AWS_ACCESS_KEY_ID" || -z "$AWS_SECRET_ACCESS_KEY" ]]; then
        echo "AWS credentials not available"
        return 1
      fi
      # Your deployment logic here
      echo "AWS credentials loaded for deployment"
    }
  '';

  # Shell aliases that use secrets
  programs.zsh.shellAliases = {
    "gc-private" = "git-clone-private";
    "dl" = "docker-login";
    "chat" = "ai-chat";
    "deploy" = "deploy-aws";
  };
}
