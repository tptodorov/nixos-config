# Desktop Shortcut Model

This language describes how macOS shortcut intent maps onto the Linux desktop
without confusing physical keys, logical modifiers, windows, workspaces or
note-taking surfaces.

## Language

**Physical chord**:
The keys held on the keyboard before system and compositor remapping.
_Avoid_: Shortcut, when the remapping layer matters

**Logical chord**:
The modifiers and key received by the compositor after remapping.
_Avoid_: Physical chord

**Mod**:
The logical Super modifier in the Umbriel shortcut map.
_Avoid_: Platform-dependent primary modifier

**Primary**:
The cross-platform role occupied by Command on macOS and by the physical
Command-position key on Linux.
_Avoid_: Super, Command, when describing a shared shortcut

**Option**:
The cross-platform role occupied by Option on macOS and by the physical
Option-position key on Linux.
_Avoid_: Alt, when describing a shared shortcut

**Hyper**:
A hold-only Caps Lock layer that emits logical Control, Alt, Shift and Super
together. Tapping it has no separate action.
_Avoid_: Caps Lock, Super

**Window movement**:
Moving the focused application window between positions, workspaces or outputs.
Horizontal movement inside a scrolling workspace instead reorders its column.
_Avoid_: Column movement, when one window moves

**Window scratchpad**:
Umbriel's global holding area for minimized application windows and their
restore locations.
_Avoid_: Notes Scratchpad, Notes quick-add popup

**Notes Scratchpad**:
The distinguished persistent Markdown note used by the official Noctalia Notes
provider for quick append operations.
_Avoid_: Window scratchpad, Notes quick-add popup

**Notes quick-add popup**:
The focused Noctalia launcher scoped to the official Notes provider for adding
or finding a note without creating an application window. Reachable by typing
the `/nt ` prefix; from 2026-09-18 no chord opens it directly.
_Avoid_: Notes panel, window scratchpad

**Notes side panel**:
The official Noctalia Notes surface for browsing and fully editing notes.
Bound to Hyper+N and Option+Primary+. as the panel id `noctalia/notes:panel`.
_Avoid_: Notes quick-add popup

**Half-window extent**:
A 50% primary or secondary layout size whose placement remains controlled by
the active layout.
_Avoid_: Left half, right half, top half, bottom half

**Active window**:
The single window receiving seat-global keyboard focus.
_Avoid_: Workspace focus

**Workspace focus**:
The window remembered as preferred within a workspace; it may not currently
receive keyboard input.
_Avoid_: Active window

**Workspace position**:
A one-based slot on the pointer-preferred output used by numbered workspace
shortcuts.
_Avoid_: Global workspace number

**Action category**:
The user's purpose for invoking an action, independent of the application or
system component that performs it and independent of how often it is used.
_Avoid_: Implementation owner, frequency tier

**Edit action**:
An action used to create, transform, transfer, enter or inspect content. This
includes clipboard operations, dictation, typing language, note capture,
definition, translation, search and shortcut help.
_Avoid_: Application action, text-only action

**Navigate action**:
An action that changes focus or location without changing window geometry.
_Avoid_: Arrange action

**Arrange action**:
An action that changes a window's placement, size, visibility or state.
_Avoid_: Navigate action

**Invoke action**:
An action whose purpose is to open an application, site or task surface.
_Avoid_: Edit action performed by an application

**System action**:
An action that controls hardware or session safety rather than user content.
_Avoid_: Generic action

**Frequency tier**:
The expected usage rate of an action: F1 continuous, F2 flow, F3 regular or F4
recovery. Frequency is independent of action category.
_Avoid_: Implementation priority

**Shared shortcut**:
A user-facing action with the same physical chord on macOS and Linux, even
when each operating system uses a different implementation owner.
_Avoid_: Identical configuration

**Application switching**:
Cycling one running application identity at a time, regardless of how many
windows each application owns. Implemented on Linux but no longer bound to a
chord there; macOS still uses it for the reserved Command+Tab switcher.
_Avoid_: All-window switching

**All-window switching**:
Selecting among individual regular windows without grouping them by
application identity.
_Avoid_: Application switching

**Same-application switching**:
Cycling regular windows owned by the active application on the active
workspace.
_Avoid_: Application switching
