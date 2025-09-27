# Starship Configuration

This document describes the Starship prompt configuration applied to your shell.

## Configuration Overview

Your Starship prompt is configured with the following features:

### Visual Changes
- **Blank line between prompts**: Adds spacing for better readability
- **Green arrow prompt**: Uses `➜` instead of the default `❯` symbol
- **Directory on same line**: Directory path shown inline with other prompt elements

### Behavior
- **Command timeout**: Set to 1000ms for better performance
- **Package module disabled**: Hides package version info from prompt
- **Directory truncation**: Shows max 8 directory levels with `…/` for truncated paths

## Applied Settings

```toml
# Inserts a blank line between shell prompts
add_newline = true
command_timeout = 1000

# Move the directory to the second line
format="$all$directory$character"

# Replace the "❯" symbol in the prompt with "➜"
[character]
success_symbol = "[➜](bold green)"

# Disable the package module, hiding it from the prompt completely
[package]
disabled = true

[directory]
truncation_length = 8
truncation_symbol = "…/"
```

## How to Apply

To apply this configuration:

```bash
# Rebuild your home configuration
home-manager switch --flake .

# Or rebuild the full system
sudo nixos-rebuild switch --flake .#blackbox

# Start a new shell to see changes
exec zsh
```

## Expected Prompt Appearance

After applying, your prompt should look like:

```
╭─ user@hostname ~/very/deep/directory/structure/…/final/dir ➜
╰─
```

Features:
- ✅ Green `➜` arrow instead of `❯`
- ✅ Blank line between command executions
- ✅ Directory truncation for long paths
- ✅ No package version info cluttering the prompt
- ✅ Fast response time (1000ms timeout)

## Customization

The configuration is managed declaratively in:
- **File**: `home/todor/modules/terminal.nix`
- **Section**: `programs.starship.settings`

To modify the prompt, edit the settings in the Nix configuration and rebuild.

## Troubleshooting

### Prompt not updating
```bash
# Ensure starship is being used
echo $STARSHIP_CONFIG

# Check if starship is in PATH
which starship

# Restart shell
exec zsh
```

### Configuration not applied
```bash
# Check generated config
cat ~/.config/starship.toml

# Rebuild home-manager
home-manager switch --flake .
```

The Starship configuration is generated automatically by Home Manager from your Nix settings.