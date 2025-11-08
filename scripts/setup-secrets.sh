#!/usr/bin/env bash
#
# Setup script for copying secrets to a new NixOS machine
# This should be run BEFORE applying the NixOS configuration
#
# Usage: ./setup-secrets.sh <target-host> [source-home-dir]
#   target-host: SSH host to copy secrets to (e.g., pero.local, 192.168.1.197)
#   source-home-dir: Optional source directory (defaults to $HOME)
#
# Example:
#   ./setup-secrets.sh pero.local
#   ./setup-secrets.sh 192.168.1.197 /home/todor
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Missing required argument: target-host"
    echo "Usage: $0 <target-host> [source-home-dir]"
    echo "Example: $0 pero.local"
    echo "Example: $0 192.168.1.197 /home/todor"
    exit 1
fi

TARGET_HOST="$1"
SOURCE_HOME="${2:-$HOME}"

print_info "Setting up secrets for new machine: $TARGET_HOST"
print_info "Source directory: $SOURCE_HOME"

# Verify SSH connectivity
print_info "Testing SSH connection to $TARGET_HOST..."
if ! ssh -o ConnectTimeout=5 "$TARGET_HOST" "echo 'SSH connection successful'" > /dev/null 2>&1; then
    print_error "Cannot connect to $TARGET_HOST via SSH"
    print_error "Please ensure:"
    print_error "  1. The target machine is accessible"
    print_error "  2. SSH is configured and running"
    print_error "  3. Your SSH key is authorized on the target"
    exit 1
fi
print_info "SSH connection verified ✓"

# Function to copy directory if it exists
copy_if_exists() {
    local src="$1"
    local dest="$2"
    local description="$3"

    if [ -d "$src" ] || [ -f "$src" ]; then
        print_info "Copying $description..."
        if scp -r "$src" "$TARGET_HOST:$dest"; then
            print_info "  ✓ $description copied successfully"
        else
            print_warn "  ✗ Failed to copy $description"
            return 1
        fi
    else
        print_warn "Skipping $description (not found at $src)"
    fi
}

# Create necessary directories on target
print_info "Creating directories on target machine..."
ssh "$TARGET_HOST" "mkdir -p ~/.config ~/.ssh" || {
    print_error "Failed to create directories on target"
    exit 1
}

# Copy secrets and configuration files
print_info "Starting secrets transfer..."
echo ""

# Clean up existing files on target to avoid permission issues
print_info "Cleaning up existing secrets on target (if any)..."
ssh "$TARGET_HOST" "rm -rf ~/.config/age ~/.config/sops ~/.password-store ~/.config/gopass" 2>/dev/null || true

# Age encryption keys
copy_if_exists "$SOURCE_HOME/.config/age" "~/.config/" "Age encryption keys"

# SOPS configuration
copy_if_exists "$SOURCE_HOME/.config/sops" "~/.config/" "SOPS configuration"

# Password store (gopass/pass)
copy_if_exists "$SOURCE_HOME/.password-store" "~/" "Password store"

# Gopass configuration
copy_if_exists "$SOURCE_HOME/.config/gopass" "~/.config/" "Gopass configuration"

# SSH keys (id_rsa and id_rsa.pub)
if [ -f "$SOURCE_HOME/.ssh/id_rsa" ]; then
    print_info "Copying SSH keys..."
    scp "$SOURCE_HOME/.ssh/id_rsa"* "$TARGET_HOST:~/.ssh/" && {
        print_info "  ✓ SSH keys copied successfully"
        # Set correct permissions on target
        ssh "$TARGET_HOST" "chmod 600 ~/.ssh/id_rsa; chmod 644 ~/.ssh/id_rsa.pub 2>/dev/null || true"
        print_info "  ✓ SSH key permissions set"
    } || {
        print_warn "  ✗ Failed to copy SSH keys"
    }
else
    print_warn "Skipping SSH keys (not found at $SOURCE_HOME/.ssh/id_rsa)"
fi

# GPG keys (if needed for gopass/pass)
if command -v gpg >/dev/null 2>&1 && gpg --list-secret-keys >/dev/null 2>&1; then
    print_info "GPG keys found on source system"
    print_warn "Note: GPG keys are NOT automatically copied for security reasons"
    print_warn "If you need GPG keys on $TARGET_HOST, export and import them manually:"
    echo ""
    echo "  # On source machine:"
    echo "  gpg --list-secret-keys  # Find the key ID"
    echo "  gpg --export-secret-keys <KEY_ID> > private-key.asc"
    echo "  gpg --export <KEY_ID> > public-key.asc"
    echo ""
    echo "  # Copy to target and import:"
    echo "  gpg --import public-key.asc"
    echo "  gpg --import private-key.asc"
    echo "  gpg --edit-key <KEY_ID> trust quit"
    echo ""
fi

# Summary
echo ""
print_info "==================================================================="
print_info "Secrets setup completed for $TARGET_HOST"
print_info "==================================================================="
echo ""
print_info "Next steps:"
echo "  1. Verify secrets are accessible on $TARGET_HOST"
echo "  2. Apply NixOS configuration:"
echo "     ssh $TARGET_HOST 'cd ~/mycfg && sudo nixos-rebuild switch --flake .#<hostname>'"
echo ""
print_info "To verify secrets on target machine:"
echo "  ssh $TARGET_HOST 'ls -la ~/.config/age ~/.config/sops ~/.password-store ~/.ssh/id_rsa'"
echo ""
