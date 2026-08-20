# Codex Ready Sound Implementation Plan

**Goal:** Play the native macOS alert when the main Codex agent stops or requests permission.
**Scope:** Add two command handlers to the existing user-level Codex hooks.
**Non-goals:** Change Computer Use, workmux, WezTerm, Claude, Pi, or subagent events.
**Risks:** Codex will skip changed user hooks until the user trusts their new definitions.

### Files

- Modify: `~/.codex/hooks.json`
- Preserve: `~/.codex/config.toml`

### Task 1: Add the sound handlers

- Outcome: `Stop` and `PermissionRequest` each contain one independent asynchronous `/usr/bin/osascript -e 'beep 1'` handler with a three-second timeout.
- Steps:
  - Snapshot the current hooks file.
  - Add only the two sound handlers.
  - Leave every existing workmux handler unchanged.
- Verification:
  - `jq empty ~/.codex/hooks.json`
  - Compare the before-and-after JSON and confirm exactly two handlers were added.
- Dependencies: none

### Task 2: Verify runtime behavior

- Outcome: The native sound command succeeds and Codex recognizes the changed hook definitions.
- Steps:
  - Run `/usr/bin/osascript -e 'beep 1'` once.
  - Start a new Codex session and use `/hooks` to review and trust the two changed definitions.
  - Confirm one sound on main-agent completion and one on a permission request.
- Verification:
  - `/usr/bin/osascript -e 'beep 1'`
  - `jq -e '.hooks.Stop and .hooks.PermissionRequest' ~/.codex/hooks.json`
- Dependencies: Task 1
