# macOS shortcut inventory

Last verified: 2026-09-17 on macOS 26.7 (25G229).

This is a snapshot of active global shortcuts on this Mac. It covers macOS,
Raycast, and the repository-managed Ghostty quick terminal. Per-application
shortcuts are out of scope.

## Legend

| Symbol | Key |
| --- | --- |
| `⌃` | Control |
| `⌥` | Option |
| `⇧` | Shift |
| `⌘` | Command |
| `🌐` | Globe/Fn |
| `✦` | Raycast Hyper: Caps Lock → left `⌃⌥⇧⌘` |

## Keyboard behavior

- Caps Lock is Raycast's Hyper key. **Include Shift** is on; **Secure Input
  Compatibility** is off.
- Control, Option, Command, Globe, and Caps Lock otherwise use their default
  macOS mappings.
- F1–F12 act as standard function keys; hold Globe for the printed media keys.
- Input sources are U.S. and Bulgarian – Phonetic.
- Dictation starts by pressing Globe twice.

## Raycast — 32 shortcuts

Raycast owns `⌘Space`; the macOS Spotlight binding is disabled.

### Launcher and workflows

| Shortcut | Action |
| --- | --- |
| `⌘Space` | Open Raycast |
| `✦M` | Open Spark |
| `✦C` | My Schedule |
| `✦D` | Define Word |
| `✦P` | My Pull Requests |
| `✦T` | Quick Translate |
| `✦J` | Jira: My Filters |
| `✦S` | Search Google |
| `⇧⌘V` | Clipboard History |
| `⌥Tab` | Switch Windows |
| `⌥⌘.` | Raycast Notes |

### Window management

| Shortcut | Action |
| --- | --- |
| `⌃⌥↓` | Bottom Half |
| `⌃⌥J` | Bottom Left Quarter |
| `⌃⌥K` | Bottom Right Quarter |
| `⌃⌥C` | Center |
| `⌃⌥D` | First Third |
| `⌃⌥E` | First Two Thirds |
| `⌃⌥G` | Last Third |
| `⌃⌥T` | Last Two Thirds |
| `⌃⌥←` | Left Half |
| `⌃⌥=` | Make Larger |
| `⌃⌥-` | Make Smaller |
| `⌃⌥Return` | Maximize |
| `⌃⌥⇧↑` | Maximize Height |
| `⌃⌥⌘→` | Move to Next Display |
| `⌃⌥⌘←` | Move to Previous Display |
| `⌃⌥Delete` | Restore |
| `⌃⌥→` | Right Half |
| `⌃⌥F` | Toggle Fullscreen |
| `⌃⌥↑` | Top Half |
| `⌃⌥U` | Top Left Quarter |
| `⌃⌥I` | Top Right Quarter |

## macOS — 34 shortcuts

### Window management

| Shortcut | Action |
| --- | --- |
| `⌘M` | Minimise |
| `⌃🌐F` | Fill |
| `⌃🌐C` | Centre |
| `⌃🌐R` | Return to Previous Size |
| `⌃🌐←` | Tile Left Half |
| `⌃🌐→` | Tile Right Half |
| `⌃🌐↑` | Tile Top Half |
| `⌃🌐↓` | Tile Bottom Half |
| `⌃⇧🌐←` | Arrange Left and Right |
| `⌃⇧🌐→` | Arrange Right and Left |
| `⌃⇧🌐↑` | Arrange Top and Bottom |
| `⌃⇧🌐↓` | Arrange Bottom and Top |

The native half-window actions overlap semantically with Raycast but use
different chords.

### Spaces and system actions

| Shortcut | Action |
| --- | --- |
| `⌃←` | Move left a Space |
| `⌃→` | Move right a Space |
| `⌃1` | Switch to Desktop 1 |
| `⌘Esc` | Game Overlay |
| `F14` | Decrease display brightness |
| `F15` | Increase display brightness |
| `Globe Globe` | Start dictation |

### Keyboard focus

| Shortcut | Action |
| --- | --- |
| `⌃F7` | Change how Tab moves focus |
| `⌃F1` | Turn keyboard access on or off |
| `⌃F2` | Move focus to the menu bar |
| `⌃F5` | Move focus to the window toolbar |
| `⌃F6` | Move focus to the floating window |
| `⌘\`` | Move focus to next window |
| `⌃F8` | Move focus to status menus |
| `⌃Return` | Show contextual menu |

### Screenshots, input, and services

| Shortcut | Action |
| --- | --- |
| `⇧⌘3` | Save a picture of the screen |
| `⌃⇧⌘3` | Copy a picture of the screen |
| `⇧⌘4` | Save a picture of a selected area |
| `⌃⇧⌘4` | Copy a picture of a selected area |
| `⇧⌘5` | Open screenshot and recording controls |
| `⌥⌘Space` | Select the next input source |
| `⌥⇧⌘S` | Summarise selected text |

## Other global shortcut

| Shortcut | Owner | Action |
| --- | --- | --- |
| `⌥⌘\`` | Ghostty | Toggle Quick Terminal |

Ghostty's shortcut is declarative in
[`home/todor/modules/terminal.nix`](../home/todor/modules/terminal.nix#L263).
The macOS and Raycast shortcuts above are currently GUI-managed rather than
declared by this repository.

## Important disabled defaults

- Spotlight `⌘Space` is disabled so Raycast can own it.
- Finder search `⌥⌘Space` is disabled; that chord changes input source instead.
- Previous input source `⌘Space` is disabled.
- Dock hiding `⌥⌘D` is disabled.
- Mission Control `⌃↑`, Application Windows `⌃↓`, and Show Desktop `F11` are
  disabled.
- No macOS Accessibility or custom Application shortcut has an active chord.

## Refresh checklist

1. Raycast → Settings → General, Keyboard, and Shortcuts.
2. System Settings → Keyboard → Keyboard Shortcuts, checking every category.
3. System Settings → Keyboard → Dictation.
4. Compare the Ghostty binding with `home/todor/modules/terminal.nix`.
