# Shell Aliases Configuration

This document describes the custom shell aliases configured for user todor and their relationship with Oh My Zsh plugin aliases.

## Aliases Added

### Directory Navigation
```bash
cd..        # cd .. (fix common typo)
..          # cd ..
...         # cd ../../../
....        # cd ../../../../
.....       # cd ../../../../
.4          # cd ../../../../
.5          # cd ../../../../../
```

### Enhanced Grep
```bash
egrep       # egrep --color=auto
fgrep       # fgrep --color=auto
hgrep       # history|grep
```

### System Utilities
```bash
bc          # bc -l (calculator with math library)
mkdir       # mkdir -pv (create parent dirs, verbose)
j           # jobs -l (list jobs)
path        # echo -e ${PATH//:/\\n} (show PATH nicely)
now         # date +"%T" (current time)
nowtime     # date +"%T" (current time)
nowdate     # date +"%d-%m-%Y" (current date)
```

### Editor Aliases
```bash
vi          # nvim
svi         # sudo nvim
vis         # nvim "+set si"
edit        # nvim
```

### Network Utilities
```bash
ping        # ping -c 5 (limit to 5 packets)
fastping    # ping -c 100 -s.2 (fast ping test)
header      # curl -I (get HTTP headers)
headerc     # curl -I --compress (get headers with compression)
```

### System Access
```bash
root        # sudo -i (become root)
su          # sudo -i (become root)
```

### Download Utilities
```bash
wget        # wget -c (resume downloads)
```

### AWS/EC2 Shortcuts
```bash
ssh2ec2     # SSH to EC2 with key from AWS_DEFAULT_REGION
scp2ec2     # SCP to EC2 with default key
```

### Development Tools
```bash
lg          # lazygit
b           # bun
cs          # coursier
bb          # ssh blackbox
gw          # gradle -t
```

## Aliases NOT Added (Conflicts with Oh My Zsh)

The following aliases were **NOT added** because they conflict with Oh My Zsh plugins:

### From Common-Aliases Plugin
```bash
# These are already provided by common-aliases plugin:
l           # ls -lFh (already exists)
ll          # ls -l (already exists)
la          # ls -lAFh (already exists)
grep        # grep --color (already exists)
h           # history (already exists)
```

### Rejected Due to Platform Differences
```bash
# These were not added due to platform compatibility:
ls='ls -G'      # macOS specific, Linux uses --color=auto
l.='ls -d .*'   # Uses --color=auto which may not work on all systems
```

## Oh My Zsh Plugin Aliases Available

Your system also has these aliases from Oh My Zsh plugins:

### Git Plugin
- `gst` (git status)
- `gco` (git checkout)
- `glog` (git log --oneline --decorate --graph)
- `ga` (git add)
- `gc` (git commit)
- Many more...

### Docker Plugin
- `dps` (docker ps)
- `dco` (docker-compose)
- `dcup` (docker-compose up)
- Many more...

### Common Aliases Plugin
- `l` (ls -lFh)
- `ll` (ls -l)
- `la` (ls -lAFh)
- `lr`, `lt`, `lS` (various ls variants)
- `-` (cd -)

## Applying Changes

To apply the new aliases:

```bash
# Rebuild home-manager configuration
home-manager switch --flake .

# Start a new shell to see changes
exec zsh

# Or source the new config
source ~/.zshrc
```

## Testing Aliases

After rebuilding, test some aliases:

```bash
# Directory navigation
..          # Should go up one directory
...         # Should go up three directories

# Editor
vi          # Should open nvim

# System utilities
path        # Should show PATH with each entry on new line
now         # Should show current time

# Development
lg          # Should open lazygit (if in git repo)
```

## Precedence

1. **Custom aliases** (defined in this config) take precedence
2. **Oh My Zsh plugin aliases** are available if not overridden
3. **System commands** are available if no alias exists

This configuration provides a comprehensive set of shell shortcuts while avoiding conflicts with existing Oh My Zsh functionality.