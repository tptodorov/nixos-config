# Shared AI agent configuration: keeps AGENTS.md identical across codex,
# Claude Code, and any other agent, on every machine, and installs a set of
# skills consistently everywhere.
#
# ~/.codex/AGENTS.md is the single source of truth (the base file, vendored
# from home/todor/config/agents/AGENTS.md). ~/.claude/AGENTS.md and
# ~/.claude/CLAUDE.md are both symlinks straight to it — every agent ends up
# reading the exact same instructions, no separate content to keep in sync.
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  llmAgentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  skillsBin = "${llmAgentsPkgs.skills}/bin/skills";
  skillsPath = lib.makeBinPath [ pkgs.git ];
  skillAgentArgs = "-a codex -a claude-code";

  # Skill packages installed via the `skills` CLI itself (skills.md registry
  # tool, not a Nix flake input) so they land in every agent's skill
  # directory the tool knows how to link into, not just ~/.agents/skills.
  #   marker: one skill name from the repo, used to skip reinstalling on
  #   every `home-manager switch` once it's already present.
  skillRepos = [
    {
      repo = "raine/workmux";
      skills = [
        "workmux"
        "worktree"
      ];
      marker = "workmux";
    }
    {
      repo = "DietrichGebert/ponytail";
      skills = null; # install every skill in the repo
      marker = "ponytail";
    }
    {
      repo = "mattpocock/skills";
      skills = null; # install every skill in the repo
      marker = "ask-matt";
    }
    {
      repo = "tt-a1i/archify";
      skills = null; # install every skill in the repo
      marker = "archify";
    }
  ];

  mkInstallCmd =
    {
      repo,
      skills,
      marker,
    }:
    let
      skillArgs =
        if skills == null then
          "${skillAgentArgs} -y -s '*'"
        else
          "${skillAgentArgs} -y " + lib.concatMapStringsSep " " (name: "-s ${name}") skills;
    in
    ''
      if [ ! -e "$HOME/.agents/skills/${marker}" ]; then
        PATH="${skillsPath}:$PATH" $DRY_RUN_CMD ${skillsBin} add ${repo} -g ${skillArgs} || true
      fi
    '';
in
{
  home.file = {
    # Base file: the only copy with real content.
    ".codex/AGENTS.md".source = ../config/agents/AGENTS.md;

    # Symlinks, not copies: always mirror the base file above.
    ".claude/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.codex/AGENTS.md";
    ".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.codex/AGENTS.md";
  };

  home.activation.installAgentSkills = lib.hm.dag.entryAfter [ "writeBoundary" ] (
    lib.concatMapStringsSep "\n" mkInstallCmd skillRepos
  );
}
