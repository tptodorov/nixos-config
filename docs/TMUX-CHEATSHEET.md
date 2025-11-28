# Tmux Cheat Sheet - Vim User Configuration

## Prefix Key
- **Prefix**: `Ctrl-a` (instead of default `Ctrl-b`)

## Session Management
```bash
# Shell aliases for session management
tm                    # Start tmux
tmn <session-name>    # Create new session
tma <session-name>    # Attach to session
tml                   # List sessions
tmk <session-name>    # Kill session

# Inside tmux
Ctrl-a d              # Detach from session
Ctrl-a s              # List sessions
Ctrl-a $              # Rename session
```

## Window Management
```bash
Ctrl-a c              # Create new window
Ctrl-a ,              # Rename window
Ctrl-a n              # Next window
Ctrl-a p              # Previous window
Ctrl-a 0-9            # Switch to window by number
Ctrl-a &              # Kill window
```

## Pane Management (Vim-style)
```bash
# Splitting
Ctrl-a |              # Split horizontally
Ctrl-a -              # Split vertically

# Navigation (Vim-style)
Ctrl-a h              # Move to left pane
Ctrl-a j              # Move to bottom pane
Ctrl-a k              # Move to top pane
Ctrl-a l              # Move to right pane

# Resizing (Vim-style, repeatable)
Ctrl-a H              # Resize left
Ctrl-a J              # Resize down
Ctrl-a K              # Resize up
Ctrl-a L              # Resize right

# Other pane commands
Ctrl-a x              # Kill pane
Ctrl-a z              # Toggle pane zoom
Ctrl-a {              # Move pane left
Ctrl-a }              # Move pane right
```

## Copy Mode (Vi-style)
```bash
Ctrl-a [              # Enter copy mode
v                     # Begin selection (in copy mode)
y                     # Copy selection and exit copy mode
r                     # Toggle rectangle selection
Ctrl-a p              # Paste buffer
q                     # Exit copy mode
```

## Configuration
```bash
Ctrl-a r              # Reload tmux config
```

## Mouse Support
- Mouse is enabled for pane selection, resizing, and scrolling
- Click to select panes
- Drag borders to resize panes
- Scroll wheel works in copy mode

## Key Features
- Windows and panes start at index 1 (not 0)
- Automatic window renumbering when windows are closed
- 10,000 line scrollback buffer
- Vi-style key bindings in copy mode
- Reduced escape time for better Vim experience
- True color support
- Focus events enabled for Vim integration
