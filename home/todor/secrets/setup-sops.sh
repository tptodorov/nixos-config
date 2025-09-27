#!/usr/bin/env bash
set -euo pipefail

# Setup script for encrypted secrets management with sops-nix
# Run this script to initialize encrypted secrets for user todor

SECRETS_DIR="$(dirname "$0")"
SOPS_DIR="$HOME/.config/sops"
AGE_DIR="$SOPS_DIR/age"
KEY_FILE="$AGE_DIR/keys.txt"

echo "🔐 Setting up encrypted secrets management for user todor"

# Check if required tools are available
if ! command -v age-keygen &> /dev/null; then
    echo "❌ age-keygen not found. Please rebuild your system configuration to include age:"
    echo "   sudo nixos-rebuild switch --flake .#blackbox"
    exit 1
fi

if ! command -v sops &> /dev/null; then
    echo "❌ sops not found. Please rebuild your system configuration to include sops:"
    echo "   sudo nixos-rebuild switch --flake .#blackbox"
    exit 1
fi

# Create directories
echo "📁 Creating sops directories..."
mkdir -p "$AGE_DIR"

# Generate age key if it doesn't exist
if [[ ! -f "$KEY_FILE" ]]; then
    echo "🔑 Generating new age key..."
    age-keygen -o "$KEY_FILE"
    chmod 600 "$KEY_FILE"
    echo "✅ Age key generated at: $KEY_FILE"
else
    echo "✅ Age key already exists at: $KEY_FILE"
fi

# Extract public key
PUBLIC_KEY=$(age-keygen -y "$KEY_FILE")
echo "📋 Your public key is: $PUBLIC_KEY"

# Create .sops.yaml if it doesn't exist
SOPS_CONFIG="$SECRETS_DIR/.sops.yaml"
if [[ ! -f "$SOPS_CONFIG" ]]; then
    echo "⚙️  Creating .sops.yaml configuration..."
    cat > "$SOPS_CONFIG" << EOF
keys:
  - &todor_key $PUBLIC_KEY

creation_rules:
  - path_regex: secrets\.yaml$
    key_groups:
    - age:
      - *todor_key
EOF
    echo "✅ Created .sops.yaml"
else
    echo "✅ .sops.yaml already exists"
fi

# Create template secrets file if it doesn't exist
SECRETS_FILE="$SECRETS_DIR/secrets.yaml"
if [[ ! -f "$SECRETS_FILE" ]]; then
    echo "📝 Creating encrypted secrets template..."

    # Create temporary unencrypted file
    TEMP_FILE=$(mktemp)
    cat > "$TEMP_FILE" << EOF
# Encrypted secrets for user todor
# Edit with: sops secrets.yaml

github_token: "ghp_your_github_token_here"
openai_api_key: "sk-your_openai_key_here"
anthropic_api_key: "sk-ant-your_anthropic_key_here"
openrouter_api_key: "sk-or-your_openrouter_key_here"
aws_access_key_id: "your_aws_access_key"
aws_secret_access_key: "your_aws_secret_key"
docker_hub_token: "your_docker_hub_token"
EOF

    # Encrypt the file
    cd "$SECRETS_DIR"
    sops --encrypt --input-type yaml --output-type yaml "$TEMP_FILE" > "$SECRETS_FILE"
    rm "$TEMP_FILE"

    echo "✅ Created encrypted secrets file: $SECRETS_FILE"
else
    echo "✅ Encrypted secrets file already exists"
fi

echo ""
echo "🎉 Setup complete! Next steps:"
echo ""
echo "1. Edit your secrets:"
echo "   cd $(pwd)"
echo "   sops secrets.yaml"
echo ""
echo "2. Add your real API keys and tokens to the encrypted file"
echo ""
echo "3. Enable encrypted secrets in your terminal module:"
echo "   # In home/todor/modules/terminal.nix, add to imports:"
echo "   ../secrets/secrets.nix"
echo ""
echo "4. Rebuild your configuration:"
echo "   home-manager switch --flake ."
echo ""
echo "⚠️  Important: Keep your age key ($KEY_FILE) safe!"
echo "   This is the only way to decrypt your secrets."
echo ""
echo "🔒 Your secrets are now encrypted and safe to commit to git!"