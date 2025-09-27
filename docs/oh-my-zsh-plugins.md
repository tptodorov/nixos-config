# Oh My Zsh Plugins Configuration

This document describes the Oh My Zsh plugins configured in your system and their functionality.

## Configured Plugins

### 🔧 **Development Tools**
- **git**: Git shortcuts and aliases (`gst`, `gco`, `glog`, etc.)
- **docker**: Docker command shortcuts (`dps`, `dco`, `dcup`, etc.)
- **npm**: Node.js package manager shortcuts
- **python**: Python development utilities
- **bun**: Bun JavaScript runtime shortcuts
- **kubectl**: Kubernetes command shortcuts (`k`, `kgp`, `kgs`, etc.)

### 🌐 **Cloud & Infrastructure**
- **aws**: AWS CLI shortcuts and completions
- **pass**: Password manager integration

### 🧰 **System & Utilities**
- **brew**: Homebrew shortcuts (useful for compatibility)
- **history**: Enhanced history search and management
- **z**: Smart directory jumping (tracks frequently used dirs)
- **jsontools**: JSON formatting and validation tools
- **common-aliases**: Useful common command aliases

## Plugin Features & Aliases

### Git Plugin
```bash
gst     # git status
gco     # git checkout
gcb     # git checkout -b
glog    # git log --oneline --decorate --graph
gp      # git push
gl      # git pull
ga      # git add
gc      # git commit
gd      # git diff
```

### Docker Plugin
```bash
dps     # docker ps
dpa     # docker ps -a
di      # docker images
dco     # docker-compose
dcup    # docker-compose up
dcdn    # docker-compose down
dex     # docker exec -it
```

### AWS Plugin
```bash
# AWS profile switching
asp     # aws-switch-profile
agp     # aws-get-profile
# Plus completions for AWS CLI commands
```

### Kubectl Plugin
```bash
k       # kubectl
kgp     # kubectl get pods
kgs     # kubectl get services
kgd     # kubectl get deployments
kdp     # kubectl describe pod
kds     # kubectl describe service
```

### JSON Tools Plugin
```bash
pp_json     # Pretty print JSON
is_json     # Check if string is valid JSON
urlencode   # URL encode string
urldecode   # URL decode string
```

### Z Plugin
```bash
z <partial-name>    # Jump to frequently used directory
# Examples:
z proj              # Jump to ~/projects
z conf              # Jump to ~/.config
```

### Common Aliases Plugin
```bash
l       # ls -lFh
ll      # ls -l
la      # ls -lAFh
lr      # ls -tRFh
lt      # ls -ltFh
lS      # ls -1FSsh
grep    # grep --color
-       # cd -
1       # cd -1
2       # cd -2
...     # (directory stack navigation)
```

### History Plugin
```bash
h       # history
hsi     # history | grep
hstat   # history stats
```

## Rebuild Configuration

To apply the new plugin configuration:

```bash
# Rebuild home-manager configuration
home-manager switch --flake .

# Start a new shell to see changes
exec zsh
```

## Testing Plugins

After rebuilding, test plugin functionality:

```bash
# Test git plugin
gst

# Test docker plugin (if Docker is installed)
dps

# Test z plugin (after visiting some directories)
cd ~/projects
cd ~/.config
z proj          # Should jump to ~/projects

# Test JSON tools
echo '{"test": "data"}' | pp_json

# Test common aliases
ll              # Should show detailed file listing

# Test kubectl (if connected to cluster)
k get nodes
```

## Notes

- Some plugins require specific tools to be installed (Docker, kubectl, AWS CLI, etc.)
- The `z` plugin learns your directory usage patterns over time
- Plugins are managed declaratively through Nix - no manual installation needed
- All supporting packages are automatically installed via `home.packages`