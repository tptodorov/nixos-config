# Herdr Cheat Sheet

[Herdr](https://herdr.dev) is an agent-aware terminal multiplexer (`herdrdev/herdr`,
packaged via the `llm-agents` flake input as `llmAgentsPkgs.herdr`). It runs
**alongside** tmux, not instead of it -- same as Omarchy Quattro ships it. Use
tmux (`docs/TMUX-CHEATSHEET.md`) for everything else; reach for herdr when you
want per-pane visibility into which agent is idle, working, blocked, or done.

## Launching

- **`Ctrl+Alt+Shift+Super+H`** -- opens a terminal running `herdr` (mirrors
  Omarchy's `Super+Ctrl+Return`). Defined in
  `modules/profiles/noctalia.nix`.
- `herdr` -- start it directly from any shell.
- `herdr session attach <name>` -- attach to a named session; add
  `--session <name>` to other commands to target it explicitly.
- `--remote-keybindings server` -- use the remote host's keybindings instead
  of your local ones when attaching over SSH.

## In-App Keys (Herdr defaults, prefix `Ctrl-b`)

Note: unlike tmux here, herdr's prefix has **not** been remapped to `Ctrl-a`
-- it ships at its own default. Reach for `Ctrl-b ?` if the two ever blur
together.

```bash
Ctrl-b ?              # Open the help panel (full keybinding list)
Ctrl-b q              # Detach from session
Ctrl-b [              # Enter copy mode for the focused pane
  h j k l             #   vim-style movement
  w b e / W B E       #   word / WORD movement
  { }                 #   paragraph movement
  / ?                 #   forward / backward search, n / N to repeat
```

Herdr also recognizes the default keybindings of Ghostty (your terminal),
kitty, WezTerm, Alacritty, Warp, and GNOME/KDE globals -- so copy/paste and
scrolling generally behave the way they already do for you.

## Dev-Layout Helpers

Ported verbatim from Omarchy Quattro's `default/bash/fns/herdr`
(`home/todor/config/shell/herdr-fns.sh`), mirroring tmux's own
`tdl`/`tds`/`tdlm`/`tsl` one-for-one. All require an active herdr session
(`$HERDR_PANE_ID` set).

```bash
hdl <ai> [<ai2>]      # Editor (85%) + AI agent (right 30%), optional 2nd AI
                      #   e.g. hdl cx        -- nvim + Claude Code
                      #        hdl c cx      -- nvim + opencode + Claude Code
hds                   # 2x2 square: nvim / hunk diff --watch / terminal / opencode
hdlm <ai> [<ai2>]     # One hdl tab per subdirectory of the current directory
hsl <count> <command> # Swarm grid of <count> panes all running <command>
                      #   e.g. hsl 4 "claude" -- 4 parallel Claude Code panes
```

`$EDITOR` is used by `hdl`/`hds` for the editor pane -- set it if you want
something other than the default.

## Resilient SSH

`ssh` is wrapped (`home/todor/config/shell/ssh-reconnect.sh`, also ported
from Omarchy) to fix two things a dropped connection otherwise leaves broken:

- **Stuck terminal state**: a remote herdr/tmux/editor session arms mouse
  tracking, focus reporting, and the alternate screen over the SSH pipe. If
  the link dies instead of exiting cleanly, those stay armed locally and
  every mouse move floods your prompt with escape junk. The wrapper disarms
  them on any exit.
- **Silent hangs**: `ServerAliveInterval 15` / `ServerAliveCountMax 3`
  (`home/todor/modules/shell.nix`) surface a dead link in ~45s instead of
  waiting on a TCP timeout. Once detected, the wrapper retries the same `ssh`
  invocation every 2s (`Ctrl-C` to stop) -- but only for an interactive
  session that had already been up 30+ seconds, so a bad password or a
  one-off remote command never gets silently replayed.

## What This Setup Does Not Have

Omarchy also ships a **Herdr HUD** bar widget (agent state + approval
prompts surfaced in the Quickshell bar) via community plugins like
`omarchy-herdr-hud` and `omaherdr`. Those are Quickshell/Omarchy-bar-specific
and have no Noctalia equivalent yet -- for now, agent state is only visible
inside herdr itself, not in the Noctalia bar.
