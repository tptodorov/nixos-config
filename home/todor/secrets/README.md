# Encrypted Secrets Management for User Todor

This directory provides **encrypted secrets management** using `sops-nix` for user todor. Your secrets are encrypted and safe to commit to git repositories.

## 🔐 Security Features

- ✅ **Encrypted at rest**: Secrets are encrypted using age encryption
- ✅ **Git-safe**: Encrypted files can be safely committed to public repos
- ✅ **User-specific**: Each user has their own encrypted secrets
- ✅ **Runtime decryption**: Secrets are only decrypted when needed
- ✅ **Key management**: Uses age keys for encryption/decryption

## 🚀 Quick Setup

### 1. Ensure Age Key is in Place

For `sops-nix` to decrypt secrets, your `age` private key must be present at the location specified in `secrets.nix`. By default, this is:

`~/.config/sops/age/keys.txt`

If you are setting up a new machine or user, **you must manually copy your existing key to this path**.

```bash
# Example:
mkdir -p ~/.config/sops/age
cp /path/to/your/backup/keys.txt ~/.config/sops/age/keys.txt
chmod 600 ~/.config/sops/age/keys.txt
```

Without the key in the correct location, `nixos-rebuild switch` will fail with a D-Bus or decryption error.

### 2. Ensure Tools Are Available

The `age` and `sops` tools are included in your system packages. If they're not available, rebuild your system:

```bash
sudo nixos-rebuild switch --flake .#blackbox
```

### 2. Run Setup Script

```bash
cd home/todor/secrets
./setup-sops.sh
```

This will:
- Generate an age encryption key
- Create sops configuration
- Create an encrypted secrets template

### 3. Edit Your Secrets

```bash
# Edit encrypted secrets file (tools are now available system-wide)
sops secrets.yaml
```

Add your real API keys, tokens, etc. The file is automatically encrypted when saved.

### 4. Enable Encrypted Secrets

Uncomment the import in `home/todor/modules/terminal.nix`:

```nix
imports = [
  ../secrets/secrets.nix  # Uncomment this line
];
```

### 5. Rebuild Configuration

```bash
home-manager switch --flake .
```

## 📁 File Structure

- `secrets.nix` - Sops-nix configuration and secret loading
- `setup-sops.sh` - Setup script for initial configuration
- `secrets.yaml` - Encrypted secrets file (safe to commit)
- `.sops.yaml` - Sops configuration (safe to commit)
- `README.md` - This documentation

## 🔑 Available Secrets

After setup, these secrets will be available as environment variables:

- `GITHUB_TOKEN` - GitHub personal access token
- `OPENAI_API_KEY` - OpenAI API key
- `ANTHROPIC_API_KEY` - Anthropic API key
- `OPENROUTER_API_KEY` - OpenRouter API key
- `AWS_ACCESS_KEY_ID` - AWS access key
- `AWS_SECRET_ACCESS_KEY` - AWS secret key
- `DOCKER_HUB_TOKEN` - Docker Hub access token

## 🛠️ Custom Functions

The configuration includes helper functions:

```bash
git-clone-private "owner/repo"  # Clone private repo with token
docker-login                    # Login to Docker Hub
ai-chat                        # AI chat with API key
deploy-aws                     # Deploy with AWS credentials
```

## 🔒 Security Best Practices

### Age Key Protection

Your age key is stored at `~/.config/sops/age/keys.txt`:

```bash
# Backup your key securely
cp ~/.config/sops/age/keys.txt ~/safe-backup-location/

# Set proper permissions
chmod 600 ~/.config/sops/age/keys.txt
```

### Key Rotation

To rotate your encryption key:

```bash
# Generate new key
age-keygen -o ~/.config/sops/age/keys-new.txt

# Update .sops.yaml with new public key
# Re-encrypt secrets with new key
sops updatekeys secrets.yaml

# Replace old key
mv ~/.config/sops/age/keys-new.txt ~/.config/sops/age/keys.txt
```

## 🌐 Multi-User Setup

Each user gets their own encrypted secrets:

```bash
# For user alice
mkdir -p home/alice/secrets
cp -r home/todor/secrets/* home/alice/secrets/
cd home/alice/secrets
./setup-sops.sh
```

## 🚨 Troubleshooting

### "sops: error: failed to decrypt"
- Check that your age key exists and has correct permissions
- Verify the public key in `.sops.yaml` matches your age key

### "Environment variables not set"
- Ensure `secrets.nix` is imported in your terminal module
- Restart your shell after rebuilding configuration
- Check that secret files are readable: `ls -la ~/.secrets/`

### "Command not found: sops"
- Rebuild your system: `sudo nixos-rebuild switch --flake .#blackbox`
- The tools are included in system packages

## 🔄 Editing Secrets

```bash
# Edit secrets (automatically encrypts on save)
sops secrets.yaml

# View encrypted file content
cat secrets.yaml  # Shows encrypted content

# Check decryption works
sops --decrypt secrets.yaml
```

## ✅ Verification

After setup, verify everything works:

```bash
# Check secrets are loaded
echo $GITHUB_TOKEN  # Should show your token

# Test custom functions
git-clone-private "test"  # Should show it's ready to clone

# Check files exist
ls -la ~/.secrets/  # Should show decrypted secret files
```

Your secrets are now encrypted and safe to push to GitHub! 🎉
