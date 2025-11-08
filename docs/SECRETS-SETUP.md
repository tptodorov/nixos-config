# Secrets Setup for New Machines

This guide explains how to set up secrets (gopass, age, sops, SSH keys) on a new NixOS machine before applying the system configuration.

## Overview

The secrets setup must be done **before** running `nixos-rebuild` because:
- SOPS needs the age keys to decrypt secrets during Home Manager activation
- Gopass store needs to be present for password management
- SSH keys are required for git operations and remote access

## Quick Start

### Prerequisites

1. Ensure you can SSH into the target machine:
   ```bash
   ssh <target-host>
   ```

2. The target machine should have basic NixOS installed with:
   - SSH server running
   - Your user account created
   - Network connectivity

### Running the Setup Script

From your existing configured machine (e.g., blackbox):

```bash
# Navigate to your NixOS config repository
cd ~/mycfg

# Run the setup script
./scripts/setup-secrets.sh <target-host>

# Examples:
./scripts/setup-secrets.sh pero.local
./scripts/setup-secrets.sh 192.168.1.197
```

### Custom Source Directory

If your secrets are in a different location:

```bash
./scripts/setup-secrets.sh <target-host> <source-home-dir>

# Example:
./scripts/setup-secrets.sh pero.local /home/olduser
```

## What Gets Copied

The setup script copies the following from your source machine:

| Item | Source | Destination | Purpose |
|------|--------|-------------|---------|
| **Age Keys** | `~/.config/age/` | `~/.config/age/` | Encryption keys for SOPS |
| **SOPS Config** | `~/.config/sops/` | `~/.config/sops/` | SOPS configuration |
| **Password Store** | `~/.password-store/` | `~/.password-store/` | Gopass/pass password database |
| **Gopass Config** | `~/.config/gopass/` | `~/.config/gopass/` | Gopass configuration |
| **SSH Keys** | `~/.ssh/id_rsa*` | `~/.ssh/` | SSH private/public keys |

## Verification

After running the setup script, verify the secrets were copied:

```bash
ssh <target-host> 'ls -la ~/.config/age ~/.config/sops ~/.password-store ~/.ssh/id_rsa'
```

### Test Gopass

SSH into the target machine and test gopass:

```bash
ssh <target-host>
gopass ls  # Should list your password store
```

**Note**: To actually retrieve passwords, you need to be in an interactive terminal:
```bash
ssh -t <target-host> gopass show test-entry
```

The `-t` flag allocates a pseudo-terminal needed for pinentry to work.

## Next Steps

After secrets are set up:

1. **Clone your config repository** (if not already present):
   ```bash
   ssh <target-host>
   cd ~
   git clone git@github.com:your-username/mycfg.git
   cd mycfg
   ```

2. **Apply NixOS configuration**:
   ```bash
   # Replace 'pero' with your hostname
   sudo nixos-rebuild switch --flake .#pero
   ```

3. **Apply Home Manager configuration** (if not included in NixOS rebuild):
   ```bash
   home-manager switch --flake .
   ```

## Troubleshooting

### SSH Connection Failed

If you can't connect to the target:
- Verify the target machine is powered on and connected to the network
- Check SSH service is running: `systemctl status sshd`
- Ensure your SSH key is in `~/.ssh/authorized_keys` on the target
- Try connecting with verbose mode: `ssh -v <target-host>`

### Permission Denied During Copy

The script automatically cleans up existing secrets directories on the target to avoid permission conflicts. If you still get permission errors:

```bash
# Manually clean up on target
ssh <target-host> 'rm -rf ~/.config/age ~/.config/sops ~/.password-store ~/.config/gopass'

# Re-run the setup script
./scripts/setup-secrets.sh <target-host>
```

### Gopass Decryption Fails

If gopass shows decryption errors when running over SSH:
- This is expected for non-interactive SSH sessions
- Use `ssh -t <target-host>` to allocate a terminal for interactive operations
- Or SSH into the machine and run gopass commands directly

### SOPS Fails During NixOS Rebuild

If SOPS can't decrypt secrets during `nixos-rebuild`:

1. Verify age key exists:
   ```bash
   ssh <target-host> 'cat ~/.config/sops/age/keys.txt'
   ```

2. Check the key matches what's in your secrets file:
   ```bash
   # On your local machine
   cd ~/mycfg
   age-keygen -y ~/.config/sops/age/keys.txt
   # Compare with recipients in home/todor/secrets/secrets.yaml
   ```

3. Re-run the setup script if the key is missing or incorrect

## GPG Keys (If Needed)

The setup script does **not** copy GPG keys automatically for security reasons.

If your password store uses GPG encryption (instead of age), you need to manually export and import GPG keys:

### Export GPG Keys (Source Machine)

```bash
# List your secret keys
gpg --list-secret-keys

# Export your keys (replace <KEY_ID> with your key ID)
gpg --export-secret-keys <KEY_ID> > ~/private-key.asc
gpg --export <KEY_ID> > ~/public-key.asc

# Copy to target
scp ~/private-key.asc ~/public-key.asc <target-host>:~/
```

### Import GPG Keys (Target Machine)

```bash
ssh <target-host>

# Import keys
gpg --import ~/public-key.asc
gpg --import ~/private-key.asc

# Set trust level
gpg --edit-key <KEY_ID>
# In GPG prompt:
trust
5  # (Ultimate trust)
quit

# Clean up key files
rm ~/private-key.asc ~/public-key.asc
```

## Security Considerations

### Secrets in Transit

- The setup script uses `scp` which encrypts data in transit over SSH
- Secrets are only copied over established SSH connections
- No secrets are written to temporary files on disk during transfer

### Target Machine Access

- Ensure the target machine is trusted
- Use full disk encryption on the target if handling sensitive passwords
- Consider the physical security of the target machine

### Network Security

- Use secure networks when transferring secrets
- Avoid public/untrusted Wi-Fi when running the setup script
- Consider using a direct ethernet connection or VPN

## Alternative: Manual Setup

If you prefer to set up secrets manually:

```bash
# On source machine
cd ~
tar czf secrets.tar.gz .config/age .config/sops .password-store .config/gopass .ssh/id_rsa*

# Copy to target
scp secrets.tar.gz <target-host>:~/

# On target machine
ssh <target-host>
cd ~
tar xzf secrets.tar.gz
chmod 600 .ssh/id_rsa
rm secrets.tar.gz
```

## See Also

- [SOPS Setup Documentation](./SOPS-INIT.md) - For information about SOPS encryption
- [Main README](../README.md) - Repository overview
- [CLAUDE.md](../CLAUDE.md) - Project structure and common commands
