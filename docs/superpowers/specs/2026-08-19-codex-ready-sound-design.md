# Codex Ready Sound Design

## Goal

Play the native macOS alert sound when the main Codex agent:

- finishes a turn; or
- is waiting for permission.

Keep the existing Computer Use notification and workmux status hooks unchanged.

## Current State

- `~/.codex/config.toml` already enables lifecycle hooks.
- `~/.codex/hooks.json` already updates workmux status on `Stop` and
  `PermissionRequest`.
- `notify` is already assigned to the Codex Computer Use client.
- `/usr/bin/osascript -e 'beep 1'` produces an audible native macOS alert on this
  machine.

## Design

Add one independent command hook to each existing event in
`~/.codex/hooks.json`:

| Event | Command | Purpose |
| --- | --- | --- |
| `Stop` | `/usr/bin/osascript -e 'beep 1'` | Signal that the main agent finished |
| `PermissionRequest` | `/usr/bin/osascript -e 'beep 1'` | Signal that Codex needs user input |

Each handler uses `"async": true` and `"timeout": 3`. A sound failure must not
delay or alter the agent lifecycle. The existing workmux handlers remain separate
and continue to run concurrently.

## Scope

This change affects Codex only. It does not:

- change Claude or Pi;
- replace the existing `notify` command;
- add WezTerm bell or desktop-notification configuration;
- sound for subagent lifecycle events; or
- add a helper script or dependency.

## Verification

1. Validate `~/.codex/hooks.json` as JSON.
2. Confirm the two existing workmux handlers are unchanged.
3. Start a new Codex session, review the changed hook definitions with `/hooks`,
   and trust them.
4. Confirm one sound on a main-agent stop and one sound on a permission request.

## Rollback

Remove only the two `osascript` hook handlers from `~/.codex/hooks.json`.
