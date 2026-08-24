# Installing Agent Skills with Nix

Research date: 2026-08-24

## Question

How should this Nix repo install third-party Agent Skills, such as
`mattpocock/skills`, so they are available to local coding agents?

## Findings

Agent Skills are ordinary directories. The portable unit is a directory with a
required `SKILL.md` and optional `scripts/`, `references/`, `assets/`, and other
support files. `SKILL.md` must have YAML frontmatter with at least `name` and
`description`; the skill name should match the parent directory name. Source:
Agent Skills specification, https://agentskills.io/specification.

Codex and ChatGPT use progressive disclosure for skills. They load skill names
and descriptions first, then load the full `SKILL.md` only when a task matches.
Large local skill sets are supported, but Codex budgets the initial skill list,
shortens descriptions first, and can omit some skills from the initial list if
there are too many. Source: OpenAI "Build skills",
https://developers.openai.com/codex/skills.

Current Codex local discovery paths are:

- Repo-local: `.agents/skills` from the current directory up to the repo root.
- User-global: `$HOME/.agents/skills`.
- Machine/admin: `/etc/codex/skills`.
- System: skills bundled with Codex.

Codex supports symlinked skill folders and follows symlink targets while
scanning these locations. Source: OpenAI "Build skills",
https://developers.openai.com/codex/skills.

The older `$skill-installer` flow is still useful for local experimentation and
can download skills from other repositories, but the current OpenAI docs
describe direct `.agents/skills` and `/etc/codex/skills` locations as the local
authoring/discovery mechanism. For reusable distribution to other people,
OpenAI recommends plugins. Source: OpenAI "Build skills",
https://developers.openai.com/codex/skills.

Matt Pocock's repository is directly relevant. Its README says the Claude Code
marketplace plugin installs a managed bundle, while Codex and other agents can
use `npx skills@latest add mattpocock/skills`; it also warns not to install both
paths because duplicate skills will appear. Source:
https://github.com/mattpocock/skills.

The repository's reusable skill directories live under `skills/<category>/<name>`.
Its Claude plugin manifest lists selected skill directories such as
`./skills/engineering/tdd`, `./skills/engineering/research`, and
`./skills/productivity/grill-me`. Source:
https://raw.githubusercontent.com/mattpocock/skills/main/.claude-plugin/plugin.json.

The repo also includes a maintainer-only `scripts/link-skills.sh` that links all
non-deprecated skill folders into both `$HOME/.claude/skills` and
`$HOME/.agents/skills`. The script says these are the local skill directories
used by Claude Code and "Codex and other Agent Skills-compatible harnesses."
Source:
https://raw.githubusercontent.com/mattpocock/skills/main/scripts/link-skills.sh.

Matt's repository currently defers native Codex plugin packaging. Its ADR says
the repo's bucketed skill layout is awkward for a Codex plugin because the
plugin manifest uses a single skills path, and a symlink-farm experiment did not
survive plugin install. Source:
https://github.com/mattpocock/skills/blob/main/.agents/adr/0002-ship-as-a-claude-code-plugin.md.

Home Manager is a good fit for this repo because it already manages dotfiles and
AI CLI packages in `home/todor/modules/development.nix`. `home.file` links files
or directories into `$HOME`. When `recursive = false`, the default for directory
sources, the target is a single symlink to the source directory. Source:
Home Manager manual,
https://nix-community.github.io/home-manager/options/home-manager/home.html.

## Recommendation

Use a pinned, declarative install:

1. Add third-party skill repositories as `flake = false` inputs.
2. Link selected leaf skill directories into `$HOME/.agents/skills/<name>` with
   Home Manager.
3. Optionally link the same selected directories into `$HOME/.claude/skills/<name>`
   if you want Claude Code to use the exact same Nix-managed skill set.
4. Do not run `npx skills@latest add ...` during Home Manager activation. It is
   mutable, network-dependent, and duplicates what Nix can pin.
5. Do not manage `$HOME/.agents/skills` as one whole directory symlink. Manage
   individual skill directories so manual or future agent-installed skills can
   coexist without replacing the entire directory.

This is a user-global install, not a machine-global install. It should make the
skills available to Codex and other Agent Skills-compatible local agents for
user `todor`. Use `/etc/codex/skills` only if the goal changes to "all users on
this NixOS machine should get these Codex skills."

## Home Manager Sketch

Add an input to `flake.nix`:

```nix
inputs = {
  mattpocock-skills = {
    url = "github:mattpocock/skills";
    flake = false;
  };
};
```

Then in `home/todor/modules/development.nix`, derive per-skill links:

```nix
let
  mattPocockSkillPaths = [
    "skills/engineering/ask-matt"
    "skills/engineering/diagnosing-bugs"
    "skills/engineering/grill-with-docs"
    "skills/engineering/setup-matt-pocock-skills"
    "skills/engineering/tdd"
    "skills/engineering/to-spec"
    "skills/engineering/to-tickets"
    "skills/engineering/implement"
    "skills/engineering/research"
    "skills/engineering/domain-modeling"
    "skills/engineering/codebase-design"
    "skills/engineering/code-review"
    "skills/productivity/grill-me"
    "skills/productivity/grilling"
    "skills/productivity/handoff"
    "skills/productivity/writing-for-agents"
  ];

  mkSkillLinks =
    dest:
    lib.listToAttrs (
      map (
        path:
        let
          name = builtins.baseNameOf path;
        in
        {
          name = "${dest}/${name}";
          value.source = inputs.mattpocock-skills + "/${path}";
        }
      ) mattPocockSkillPaths
    );
in
{
  home.file =
    {
      # existing entries...
    }
    // mkSkillLinks ".agents/skills";

  # Optional, only if you are not also using the Claude Code marketplace plugin:
  # home.file = existingHomeFiles
  #   // mkSkillLinks ".agents/skills"
  #   // mkSkillLinks ".claude/skills";
}
```

## NixOS Admin-Wide Sketch

For all users on a NixOS host, install the same selected skill directories under
`/etc/codex/skills`. This is Codex's documented admin scope; it is not guaranteed
to affect every non-Codex agent.

```nix
{ inputs, lib, ... }:
let
  mattPocockSkillPaths = [
    "skills/engineering/tdd"
    "skills/engineering/research"
    "skills/engineering/code-review"
    "skills/productivity/grilling"
  ];

  mkEtcSkill =
    path:
    let
      name = builtins.baseNameOf path;
    in
    {
      name = "codex/skills/${name}";
      value.source = inputs.mattpocock-skills + "/${path}";
    };
in
{
  environment.etc = lib.listToAttrs (map mkEtcSkill mattPocockSkillPaths);
}
```

Keep the selected list explicit. Matt's repository includes deprecated and
in-progress skills, so "link every `SKILL.md` under the repo" is easy but noisier
than a curated list.

## Operational Notes

After updating the flake input, run the normal Home Manager or NixOS rebuild.
Restart already-running agents if they do not pick up new skills immediately.
OpenAI says Codex detects skill changes automatically, but restart is still the
documented fallback.

This repo currently applies the pattern for `DietrichGebert/ponytail`, linking
the six upstream skill directories under `skills/` into `$HOME/.agents/skills`.
It also applies the same pattern for:

- `tt-a1i/archify`, whose README documents Codex installs under
  `$HOME/.agents/skills` and whose skill root is `archify/SKILL.md`.
- `Egonex-AI/Understand-Anything`, whose installer maps Codex to
  `$HOME/.agents/skills` with one link per skill. This repo links the nine
  `understand-*` skill directories plus a Nix-built plugin root at
  `$HOME/.understand-anything-plugin`. The build precompiles
  `packages/core/dist/` with pinned `pnpm` dependencies so first use does not
  try to build inside the read-only Nix store.
- `Graphify-Labs/graphify`, whose README documents a manual
  `$HOME/.claude/skills/graphify/SKILL.md` install but whose repository stores
  the Codex skill content at `graphify/skill.md`. This repo normalizes that
  lowercase filename to `SKILL.md` in a small Nix store directory and links that
  directory into `$HOME/.agents/skills/graphify`. The Graphify CLI is not yet
  packaged here; upstream's skill currently resolves it through `uv tool run
  --from graphifyy`, which downloads Python packages outside the flake lock.

To update a pinned skill input later:

```sh
nix flake lock --update-input ponytail-skills
```

Then rebuild Home Manager/NixOS.

If a target skill directory already exists as a real, non-Home-Manager-managed
directory, Home Manager will report a collision. Move or delete that directory
before managing that skill declaratively.

## Caveats

`$HOME/.codex/skills` may still exist from `$skill-installer` or older Codex
flows, and this machine currently has skills there. For cross-agent installs,
prefer `$HOME/.agents/skills`; it is the current documented user-global Agent
Skills location and is not Codex-specific.

Skills are read from the Nix store with this approach. That is good for
reproducibility, but it means editing installed skill files directly is not the
workflow. Fork or vendor the skill repo if local modifications are needed.
