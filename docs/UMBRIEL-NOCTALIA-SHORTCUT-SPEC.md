# Cross-platform shortcut specification — Umbriel + Noctalia

Status: **approved for Linux implementation**

Last updated: 2026-09-18

Linux target: `blackbox`

Source inventory: [`MACOS-SHORTCUTS.md`](./MACOS-SHORTCUTS.md)

## 1. Outcome

Define one ergonomic physical shortcut map for macOS and Linux, then implement
its Linux side in the Umbriel + Noctalia session already installed on
`blackbox`. The later macOS implementation must use the same physical chords,
but is not part of this change.

Do not add Hyprland. Umbriel already provides the retained window operations:
directional focus and movement, workspace and output movement, centering,
maximizing, fullscreen, scratchpad-backed minimization and JSON IPC.

The existing pinned stack remains unchanged:

- Umbriel `42e7ef38ae938f4796b70b16fc1238d9c96cf01f`;
- Noctalia `8c52cb71b5bcafbf67bfb8e659f1fc45f882a008`;
- Noctalia Greeter `d9fe1d7851464a923020d39efae8a6e3561f0d63`;
- Noctalia starts only with `umbriel-session.target`;
- Umbriel, Noctalia, the greeter, XWayland and the 4K output are already
  configured in `hosts/blackbox/modules/noctalia.nix`.

Primary references:

- [Umbriel actions](https://docs.noctalia.dev/umbriel/actions/)
- [Umbriel keybinds](https://docs.noctalia.dev/umbriel/keybinds/)
- [Umbriel IPC](https://docs.noctalia.dev/umbriel/ipc/)
- [Noctalia integration](https://docs.noctalia.dev/noctalia/compositor-settings/umbriel/)
- [Noctalia surfaces IPC](https://docs.noctalia.dev/noctalia/ipc/surfaces/)
- [Noctalia system-control IPC](https://docs.noctalia.dev/noctalia/ipc/system-controls/)
- [Noctalia launcher](https://docs.noctalia.dev/noctalia/launcher/)
- [Pinned Umbriel example config](https://github.com/noctalia-dev/umbriel/blob/42e7ef38ae938f4796b70b16fc1238d9c96cf01f/examples/config.toml)
- [Pinned Umbriel Home Manager module](https://github.com/noctalia-dev/umbriel/blob/42e7ef38ae938f4796b70b16fc1238d9c96cf01f/nix/home-module.nix)

## 2. Design rules and fixed decisions

### 2.1 Categories

Classify shortcuts by the user's intent, not by the component that implements
them:

| Category | Intent |
| --- | --- |
| Edit | Create, transform, transfer, enter or inspect content. |
| Navigate | Change focus or location without changing window geometry. |
| Arrange | Change a window's placement, size, visibility or state. |
| Invoke | Open an application, site or task surface. |
| System | Control hardware or session safety. |

Clipboard history, dictation, typing language, note capture, definition,
translation, search and shortcut help are Edit actions. Category and frequency
are independent.

### 2.2 Frequency tiers

| Tier | Expected use | Ergonomic requirement |
| --- | --- | --- |
| F1 — continuous | Dozens of times per hour | Preserve the easiest established chord. Never displace it with a global action. |
| F2 — flow | Many times per session | One easy modifier role plus a mnemonic, direction or Tab. |
| F3 — regular | Daily or weekly | A memorable two-modifier family or Hyper mnemonic is acceptable. |
| F4 — recovery | Rare, diagnostic or safety use | Discoverability and collision avoidance matter more than speed. |

These rankings are provisional, not telemetry-derived. Reassess optional
mnemonic launches after one week of normal use; required F4 safety actions stay
rare by design.

### 2.3 Normative decisions

1. Use the same physical chord on macOS and Linux for every shared action.
   Platform-specific implementation details may differ.
2. Preserve the application-owned Primary namespace. The deliberate shared
   exceptions are copy, cut, paste, clipboard history, launcher, application
   switching, same-application switching, directional window focus and
   minimize.
3. Use Hyper for global Edit and Invoke mnemonics and workspace navigation.
4. Use `Control+Option` for Arrange actions.
5. Directional focus means neighboring-window focus, not output focus. There
   is no output-focus shortcut.
6. Keep separate scopes for application switching, all-window switching and
   same-application switching.
7. Use Hyper+1 through Hyper+9 for direct workspace selection. Do not add a
   direct move-window-to-number layer.
8. Prefer `Control+Option+Shift+Arrow` for moving windows across displays and
   workspaces, but bind it only after every regular keyboard passes `wev`.
   Use the punctuation fallback in section 7.3 if any keyboard fails.
9. Accept Umbriel's layout semantics: horizontal local movement reorders the
   focused column; vertical local movement reorders a window within it.
10. Keep center, maximize, fullscreen and minimize. Omit explicit scratchpad
    show/restore and the misleading half-window direction aliases.
11. Keep WezTerm and reuse applications already declared in Home Manager.
12. Use the official Noctalia Notes `/nt` provider for a focused quick-add
    popup. Do not patch the plugin.
13. Do not use Globe/Fn, global F-keys, plain `Control+Shift` chords, a quick
    terminal, screenshot approximations or a global settings chord.
14. Treat Nix as Noctalia's declared default, while preserving supported GUI
    overrides. Never manage generated Noctalia runtime state directly.
15. Build and activate one complete configuration. The implementation groups
    are ordering and validation gates, not partial live maps.

Hyper is a physical Caps hold that emits logical Control, Alt, Shift and Super.
It is one easy physical modifier, not a four-modifier ergonomic penalty.

The map accepts one accessibility tradeoff: Hyper occupies Caps, and the
Arrange family uses `Control+Option`; both can be VoiceOver modifiers on macOS.
Accessibility shortcuts are currently inactive. Revisit this map before
enabling VoiceOver.

## 3. Existing state and required corrections

The current Umbriel keybind table is a smoke-test configuration. Defining
`[keybinds]` replaces Umbriel's built-in table, so every retained binding must
be explicit.

The Linux implementation must:

- add Caps-to-Hyper and retain the PC Alt/Super physical-position swap;
- establish the shared Edit, Navigate, Arrange, Invoke and System map;
- make `Primary+C/X/V` work in GUI applications and WezTerm without sending
  terminal `Ctrl+C` for copy;
- provide distinct application, all-window and same-application switching;
- start Voxtype with Umbriel and move dictation to Hyper+D;
- make workspace positions 1 through 9 stable on each regular output;
- pin the official Notes and Translator plugins;
- retain the shortcut-inhibition safety escape;
- correct stale greeter comments in `flake.nix` and the module.

Keep Niri as the greeter's default session during this rollout. Switching the
default to Umbriel is a separate one-line follow-up after acceptance.

## 4. Ownership and repository changes

Keep the Linux pilot in its existing blackbox ownership seam.

| File | Required change |
| --- | --- |
| `flake.nix` | Add a non-flake `github:noctalia-dev/official-plugins` input and correct the stale greeter comment. Do not change the installed Umbriel, Noctalia or greeter inputs. |
| `flake.lock` | Update with Nix tooling for the plugin input. Never edit manually. |
| `hosts/blackbox/modules/noctalia.nix` | Add keyd, the two helper derivations, plugin source, application variables and the complete Umbriel map. |
| `home/todor/modules/terminal.nix` | Make WezTerm's Primary copy and paste behavior portable instead of unconditionally calling macOS-only `pbpaste`. |
| `home/todor/modules/desktop-apps.nix` | No change. Reuse its applications, `wtype`, Voxtype and desktop entries. |
| `docs/MACOS-SHORTCUTS.md` | No change. It remains a snapshot of the current Mac, not the future map. |

Do not build a general compositor abstraction. The canonical layer is this
physical map; each platform should use its native implementation vocabulary.

## 5. Modifier model

### 5.1 Physical roles

The normative tables use physical role names:

| Role | macOS | Linux PC keyboard after remapping |
| --- | --- | --- |
| Primary | Command | Key in the Command position: physical Alt, logical Super/`Mod` |
| Option | Option | Key in the Option position: physical Super, logical Alt |
| Control | Control | Control |
| Hyper | Caps | Caps via keyd, emitting Control+Alt+Shift+Super |

This naming makes the shared map independent of keycap labels.

### 5.2 Caps as Hyper

Add keyd at the NixOS layer:

```nix
services.keyd = {
  enable = true;
  keyboards.default = {
    ids = [ "*" ];
    settings.main.capslock = "layer(hyper)";
    extraConfig = ''
      [hyper:C-A-S-M]
    '';
  };
};
```

Caps has no tap action and must not toggle Caps Lock. Test the system-wide
mapping in Umbriel, Niri and GNOME. If `keyd monitor` shows that `"*"` captures
an unwanted virtual keyboard, replace it with observed physical device IDs.

### 5.3 Linux keyboard layout

```nix
general.mod_key = "Super";

input.keyboard = {
  layout = "us,bg";
  variant = ",phonetic";
  options = "altwin:swap_alt_win";
  repeat_rate = 50;
  repeat_delay = 250;
};
```

Do not copy `grp:rwin_toggle` into Umbriel. Hyper letter bindings must be
tested under both US and Bulgarian layouts.

## 6. Shortcut architecture

| Physical family | Purpose |
| --- | --- |
| `Primary+C/X/V` | F1 application editing. |
| `Primary+Tab`, `Option+Tab`, `Primary+grave` | Application, all-window and same-application switching. |
| `Primary+Control+Arrow` | Directional neighboring-window focus. |
| `Hyper+Left/Right`, `Hyper+1…9` | Sequential and direct workspace navigation. |
| `Control+Option+Arrow` | Arrange within the current workspace. |
| `Control+Option+Shift+Arrow` | Preferred cross-display/workspace movement. |
| `Hyper+letter` | Global Edit or Invoke mnemonic. |
| Dedicated XF86 keys | Hardware controls. |

Plain Primary letters, digits and arrows remain application-owned unless an
exact exception appears in section 7. In particular, no global
`Primary+Arrow`, `Primary+number` or generic `Primary+Shift+letter` family is
created.

## 7. Complete shared shortcut map

This section is normative. The physical chord must match on macOS and Linux.
The action is the contract; the Linux implementation named here is local to
Umbriel and Noctalia.

Use `repeat = false` by default. Directional focus, directional movement,
workspace stepping, volume adjustment and brightness adjustment may repeat
while held. The Noctalia window switcher and both mute toggles must not repeat.

### 7.1 Edit

| Tier | Physical chord | Shared action | Linux implementation |
| --- | --- | --- | --- |
| F1 | `Primary+C` | Copy | Emit a tested GUI-safe copy event; configure WezTerm explicitly. |
| F1 | `Primary+X` | Cut | Emit a tested GUI-safe cut event; configure WezTerm explicitly if needed. |
| F1 | `Primary+V` | Paste | Emit a tested GUI-safe paste event; configure WezTerm explicitly. |
| F1 | `Primary+Shift+V` | Clipboard history | `noctalia msg panel-toggle clipboard` |
| F2 | `Hyper+D` | Dictation | `voxtype record toggle` |
| F2 | `Hyper+L` | Next typing language | `keyboard-layout-next` |
| F2 | `Hyper+N` | Notes quick-add | `noctalia msg panel-toggle launcher "/nt "` |
| F3 | `Hyper+W` | Define word | `macos-workflow define` |
| F3 | `Hyper+T` | Translate | Open the Noctalia launcher with `/tr `. |
| F3 | `Hyper+S` | Web search | `macos-workflow google` |
| F4 | `Hyper+/` | Shortcut cheatsheet | `cheatsheet-toggle` |

`Primary+Shift+V` is a deliberate global exception: clipboard history is used
as a paste operation frequently enough to outrank application-specific “paste
without formatting.”

For Linux copy, cut and paste, first test the conventional alternate events
`Control+Insert`, `Shift+Delete` and `Shift+Insert` through `wtype`. Never fall
back to injecting `Control+C/X/V` globally: in a terminal that would turn copy
into interrupt. Do not accept the shared map until Brave, Obsidian, Nautilus,
WezTerm, one native Wayland application and one XWayland application pass.

The Notes popup must open focused on the active display, toggle closed on a
second press, close on Escape, preserve notes as Markdown under
`~/Documents/Notes`, and never create or move an Umbriel application window.
The official Notes side panel remains available separately for browsing and
full editing.

### 7.2 Navigate

| Tier | Physical chord | Shared action | Linux implementation |
| --- | --- | --- | --- |
| F2 | `Primary+Tab` | Switch to the next application | `umbriel-cycle-window application` |
| F2 | `Option+Tab` | Switch among all individual windows | `noctalia msg window-switcher` with MRU enabled |
| F2 | `Primary+grave` | Switch among windows of the active application | `umbriel-cycle-window same-application` |
| F2 | `Primary+Control+Left/Right/Up/Down` | Focus neighboring window | `window-focus-left/right/up/down` |
| F2 | `Hyper+Left/Right` | Previous/next workspace | `workspace-previous/next` |
| F3 | `Hyper+1…9` | Select workspace position 1…9 | `workspace-switch:1…9` |

`Primary+Control+Arrow` replaces the old output-focus layer. Neighboring-window
focus follows layout geometry; output focus has no binding.

The three switchers have intentionally different scopes. `Primary+Tab` cycles
one application identity at a time, `Option+Tab` exposes individual windows,
and `Primary+grave` stays within the active application's regular windows on
the active workspace. Do not route `Primary+Tab` to Noctalia's per-window
switcher or label that surface an application switcher.

Set `shell.window_switcher.mru = true` for the `Option+Tab` Noctalia surface.

Keep dynamic workspaces but set `min_workspaces = 9` on every regular output
reported by `umbriel outputs`. Umbriel's numeric selection is pointer-owned:
the pointer-preferred output receives the action. Test with pointer and keyboard
focus on different displays.

### 7.3 Arrange

| Tier | Physical chord | Shared action | Preferred Linux implementation |
| --- | --- | --- | --- |
| F2 | `Control+Option+Left/Right` | Move/reorder left/right in the workspace | `column-move-left/right` |
| F2 | `Control+Option+Up/Down` | Move/reorder up/down in the workspace | `window-move-up/down` |
| F2 | `Control+Option+Return` | Toggle maximize | `window-toggle-maximize-to-edges` |
| F3 | `Control+Option+Shift+Left/Right` | Move window to previous/next display | `window-move-to-output-previous/next` |
| F3 | `Control+Option+Shift+Up/Down` | Move window to previous/next workspace | `window-move-to-workspace-previous/next` |
| F3 | `Control+Option+F` | Toggle fullscreen | `window-toggle-fullscreen` |
| F3 | `Control+Option+C` | Center floating window | `window-center` |
| F3 | `Primary+M` | Minimize | `window-move-to-scratchpad` |

The cross-display/workspace arrow family is conditional. Before implementation,
verify all four physical chords with `wev` on every regular keyboard. If any
chord is missing or ambiguous, do not bind a partial arrow family. Use this
complete fallback instead:

| Tier | Physical chord | Shared action |
| --- | --- | --- |
| F3 | `Control+Option+[` / `Control+Option+]` | Move window to previous/next workspace. |
| F3 | `Control+Option+,` / `Control+Option+.` | Move window to previous/next display. |

The known-ghosted `Control+Option+Primary+Arrow` family must not be used. Bind
only the preferred family or the fallback, never both.

Center is native floating-window centering and has no invented tiled meaning.
Maximize and fullscreen toggle back to the previous state. Minimized windows
use Umbriel's implicit default scratchpad; explicit show/restore shortcuts are
platform-local recovery controls only if live use proves they are needed.

### 7.4 Invoke

Define application commands once in the module's existing `let` block:

```nix
shortcutApps = {
  mail = "${pkgs.gtk3}/bin/gtk-launch notion-mail";
  calendar = "${pkgs.gtk3}/bin/gtk-launch notion-calendar";
  terminal = "${pkgs.wezterm}/bin/wezterm";
  browser = "${pkgs.brave}/bin/brave";
  files = "${pkgs.nautilus}/bin/nautilus";
  notes = "${pkgs.obsidian}/bin/obsidian";
};
```

| Tier | Physical chord | Shared action | Linux implementation |
| --- | --- | --- | --- |
| F2 | `Primary+Space` | Launcher | `noctalia msg panel-toggle launcher` |
| F2 | `Hyper+Return` | Terminal | `shortcutApps.terminal` |
| F2 | `Hyper+B` | Browser | `shortcutApps.browser` |
| F2 | `Hyper+E` | Files | `shortcutApps.files` |
| F2 | `Hyper+O` | Obsidian | `shortcutApps.notes` |
| F3 | `Hyper+M` | Mail | `shortcutApps.mail` |
| F3 | `Hyper+C` | Calendar | `shortcutApps.calendar` |
| F3 | `Hyper+P` | GitHub pull requests | Open `https://github.com/pulls` directly. |
| F3 | `Hyper+J` | Jira filters | `macos-workflow jira` |

Inline the one-use GitHub URL. Do not wrap direct application launches, fixed
URLs or native actions. Add another Hyper launch only after it demonstrates at
least F3 usage.

### 7.5 System

| Tier | Physical chord | Shared action | Linux implementation |
| --- | --- | --- | --- |
| F4 | `Hyper+Escape` | Toggle shortcut inhibition | `shortcuts-inhibit-toggle`, `allow_when_inhibited = true` |
| F2/F3 | Volume up/down | Adjust volume | `XF86AudioRaiseVolume` / `XF86AudioLowerVolume` |
| F3 | Volume mute | Toggle output mute | `XF86AudioMute` |
| F3 | Microphone mute | Toggle microphone mute | `XF86AudioMicMute` |
| F2/F3 | Brightness up/down | Adjust brightness | `XF86MonBrightnessUp` / `XF86MonBrightnessDown` |

Volume and brightness adjustments may repeat and may run while locked where
the pinned stack supports it. Volume mute and microphone mute use
`repeat = false`.

Start the existing Voxtype daemon once with Umbriel:

```text
env YDOTOOL_SOCKET=/run/ydotoold/socket voxtype --no-hotkey --driver=ydotool,wtype daemon
```

Do not enable Voxtype's evdev hotkey or add another service.

## 8. Helper programs

Define exactly two helpers with `pkgs.writeShellApplication` in
`hosts/blackbox/modules/noctalia.nix`. Put only the helper derivations in
`home-manager.users.todor.home.packages`; keep runtime inputs on the helpers for
closure correctness. `jq` and `xdg-utils` already belong to shared Home Manager
modules and must not be duplicated as top-level packages.

### 8.1 `umbriel-cycle-window`

Supported modes are exactly:

```text
application same-application
```

Both modes read one `umbriel windows --json` snapshot, operate only on regular
windows with non-empty `app_id` and empty `scratchpad`, and focus the selected
ID with `umbriel msg "window-focus:<id>"` without shell evaluation.

- `same-application`: preserve snapshot order, filter to the active `app_id`
  and active workspace, select the next window after the active one, wrap, and
  no-op with fewer than two matches.
- `application`: collapse windows by `app_id`, start after the active
  application, wrap, and focus one remembered regular window from the selected
  application. Prefer Umbriel's remembered focus; otherwise use the first
  snapshot match. One invocation advances one application, never merely the
  next window of the same application.

The pinned schema exposes `id`, `active`, `focused`, `app_id`, `workspace` and
`scratchpad`; the command returns the array directly. Use `active` for
seat-global focus. Do not add a daemon, overlay or persistent MRU database.

Runtime inputs: the pinned Umbriel package and `jq`.

### 8.2 `macos-workflow`

Supported subcommands are exactly:

```text
define jira google
```

- `jira`: require exactly one `JIRA_URL=` assignment in
  `~/.config/wtf/jira.env`, reject control characters and non-HTTP(S) schemes,
  and open `${JIRA_URL%/}/secure/ManageFilters.jspa?search=Search`;
- `define`: collect free-form text with `noctalia dmenu`, URL-encode the full
  `define:<text>` query with `jq @uri`, and open Google Search;
- `google`: collect free-form text with `noctalia dmenu`, URL-encode it with
  `jq @uri`, and open Google Search.

Cancellation exits successfully. Invalid Jira configuration sends a concise
Noctalia notification and exits non-zero. Never source `jira.env`, use `eval`,
or interpolate input into `sh -c`; quotes and shell metacharacters remain data.

Runtime inputs: Noctalia, `jq` and `xdg-utils`.

## 9. Noctalia plugins

Enable only:

- `noctalia/notes` for Hyper+N and the separately accessible side panel;
- `noctalia/translator` for Hyper+T and `/tr`.

Use a locked non-flake `github:noctalia-dev/official-plugins` input as a
read-only path source, and set plugin auto-update to `none`. Do not add the
community source, GitHub PR plugin or screen-recorder plugin.

Do not duplicate the pinned manifests' current defaults in `plugin_settings`:
Notes already uses `~/Documents/Notes` with `md`, and Translator already uses
Google with target language `en`. The lock owns drift; add an override only
when the desired value differs.

Validate the settings shape against the pinned Noctalia module before
committing. Keep tokens out of Nix. Inspect the effective merged configuration
after activation and resolve conflicts through Noctalia's UI, never by editing
or owning its generated runtime state.

References: [official plugin catalog](https://docs.noctalia.dev/noctalia/plugins/official-plugins/)
and [plugin management](https://docs.noctalia.dev/noctalia/plugins/using-plugins/).

## 10. Applications and services

| Role | Implementation | State |
| --- | --- | --- |
| Shell, launcher, clipboard, all-window switcher | Noctalia | Existing and Umbriel-scoped. |
| Window manager | Umbriel | Existing and pinned. |
| Hyper modifier | keyd | Add NixOS service. |
| Application and same-app cycling | `umbriel-cycle-window` | Add one helper. |
| Terminal | WezTerm | Existing; make Primary copy/paste portable. |
| Browser | Brave | Existing. |
| Mail | Notion Mail Brave app | Existing XDG entry. |
| Calendar | Notion Calendar Brave app | Existing XDG entry. |
| Files | Nautilus | Existing. |
| Notes | Obsidian plus Noctalia Notes | Existing app; add official plugin. |
| Translation | Noctalia Translator | Add official plugin. |
| Dictation | Voxtype | Existing; start with Umbriel and bind Hyper+D. |
| Secrets | GNOME Keyring / Secret Service | Existing; no credentials in Nix. |

Do not install another terminal, launcher, clipboard daemon, notification
daemon, lock screen or wallpaper daemon.

## 11. Deliberately omitted or platform-local

| Shortcut family | Decision | Reason |
| --- | --- | --- |
| Output focus | Omit | `Primary+Control+Arrow` is neighboring-window focus; application and window switchers cover discovery. |
| Direct window move to workspace 1…9 | Omit | Hyper already contains Shift, so there is no distinct Hyper+Shift layer; sequential movement is sufficient initially. |
| Half-window directions | Omit from shared core | Umbriel exposes width/height extents, not the edge-placement semantics used on macOS. |
| Scratchpad show/restore | Platform-local F4 only if needed | The shared action is minimize; recovery mechanics differ by platform. |
| Thirds and quarters | Omit | Explicitly unused. |
| Close, floating, pinned, overview and session quit | Omit | Application, Noctalia UI and CLI paths exist; do not allocate speculative chords. |
| Grow/shrink and maximize height | Omit | Lower frequency and no agreed shared semantic. |
| Globe/Fn and global F1–F15 | Omit | Hardware-dependent or owned by development tools. |
| Plain `Control+Shift+…` | Application-owned | Required by terminal workflows. |
| Quick terminal | Omit | Explicitly unused. |
| Accessibility/menu focus | Omit | No reliable cross-toolkit Wayland equivalent. |
| Selected-text summary | Omit | Requires a separate privacy, provider and selection design. |
| Settings and screenshots | Omit | Not required; screenshot approximations do not match the recorded actions. |

## 12. Implementation and validation order

Build the complete `blackbox` closure before one activation.

### Group 1 — physical foundation

1. Verify `Control+Option+Shift+Arrow` with `wev` on every regular keyboard and
   select either the full preferred family or the full fallback.
2. Add keyd Hyper, explicit `Mod = Super`, US/Bulgarian layout and the
   Alt/Super swap.
3. Set the dynamic workspace floor to nine on every regular output.
4. Make WezTerm's Primary copy/paste handling cross-platform.

### Group 2 — F1 and F2 flow

1. Add Primary copy, cut, paste and clipboard history.
2. Add application, all-window and same-application switching.
3. Add directional focus, sequential workspaces and local window movement.
4. Add launcher, dictation, language, Notes and the F2 application launches.
5. Add maximize and shortcut inhibition.

### Group 3 — F3 and F4 actions

1. Pin the official plugin source and enable Notes and Translator.
2. Add direct workspace selection, cross-display/workspace movement and the
   remaining Arrange actions.
3. Add Define, Translate, Search, remaining application/site launches,
   cheatsheet and hardware controls.
4. Validate the effective Noctalia configuration.

Then run all static checks, build the complete closure, activate once, and run
the live matrix. Making Umbriel the greeter default remains a later follow-up.

## 13. Validation and acceptance

### 13.1 Static checks

Run sequentially:

```text
nix fmt
git diff --check
nix flake check --no-build
nix eval --json .#nixosConfigurations.blackbox.config.programs.umbriel.enable
nix eval --json .#nixosConfigurations.blackbox.config.programs.noctalia.enable
```

Build the `blackbox` closure without activating when a Linux builder is
available. A macOS evaluation failure for a Linux closure is not Linux failure
evidence.

After activation:

```text
umbriel validate
noctalia config validate
noctalia config export merged
noctalia msg plugins list
systemctl --user status umbriel-session.target
systemctl --user status noctalia.service
keyd monitor
wev
```

### 13.2 Live matrix

Test at least:

1. `Primary+C/X/V` in Brave, Obsidian, Nautilus, WezTerm, one native Wayland
   application and one XWayland application; terminal copy must not send
   interrupt;
2. `Primary+Shift+V` clipboard history;
3. `Primary+Tab` across applications, `Option+Tab` across individual windows,
   and `Primary+grave` across same-app windows on one workspace;
4. `Primary+Control+Arrow` with windows in every direction and across two
   outputs, confirming that it follows windows rather than focusing an empty
   output;
5. Hyper+Left/Right and Hyper+1…9 with pointer and focus on different outputs;
6. every local and cross-workspace/display Arrange chord on each regular
   keyboard;
7. maximize, fullscreen, floating center and scratchpad-backed minimize;
8. every Hyper mnemonic under US and Bulgarian layouts;
9. Notes quick-add, translation, definition, search, Jira and fixed URL launch;
10. dictation into native Wayland and XWayland applications;
11. held `Option+Tab`, output mute and microphone mute, confirming no repeat;
12. held volume and brightness adjustments, lock-screen behavior where
    supported, and shortcut-inhibition recovery;
13. Niri and GNOME after enabling keyd;
14. effective Noctalia configuration and locked plugin source after runtime
    overrides.

Record failures by physical keyboard and application.

### 13.3 Acceptance criteria

The Linux implementation is complete when:

- Caps is a reliable hold-only Hyper key in Umbriel, Niri and GNOME;
- every row in section 7 has a live pass or a documented platform-specific
  limitation accepted before activation;
- F1 Primary copy, cut and paste work without breaking WezTerm semantics;
- the three switch scopes are distinct and correctly labeled;
- directional focus targets windows and output focus is absent;
- one complete cross-display/workspace movement family works on every regular
  keyboard;
- workspace positions 1 through 9 remain stable on every regular output;
- Hyper mnemonics work under both configured layouts;
- Noctalia discrete surfaces and mute toggles do not repeat;
- Notes and Translator come only from the locked official plugin source;
- no omitted shortcut family has re-entered the map;
- `umbriel validate` and `noctalia config validate` pass;
- Niri, GNOME and terminal workflows are not regressed.

After one week, review actual use by action and tier. Remove unused optional
F3/F4 bindings before adding more shortcuts; retain required recovery and
safety actions.

## 14. Agent guardrails

- Preserve unrelated and untracked documentation files.
- Do not update the installed Umbriel, Noctalia or greeter inputs.
- Do not introduce Hyprland.
- Do not start Noctalia outside `umbriel-session.target` or DMS inside it.
- Do not manually edit `flake.lock` or Noctalia runtime state.
- Do not add helpers for direct Umbriel, Noctalia or fixed-URL actions.
- Do not add a Voxtype service or enable its evdev hotkey.
- Do not patch official plugins.
- Do not use shell evaluation for user-entered text or Jira settings.
- Do not bind both preferred and fallback movement families.
- Do not activate a partial map.
- Do not modify macOS shortcuts in the Linux implementation change.
- Do not switch the greeter default session in the shortcut change.
