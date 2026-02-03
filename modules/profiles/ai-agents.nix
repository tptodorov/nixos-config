# AI Coding Agents configuration using llm-agents.nix
# This profile provides access to 30+ AI coding agents and development tools
{
  pkgs,
  inputs,
  ...
}:
{
  # Access to llm-agents packages via overlay
  nixpkgs.overlays = [ inputs.llm-agents.overlays.default ];

  # System packages from llm-agents
  environment.systemPackages = with pkgs; [
    llm-agents.amp # Amp - Agentic coding tool from Sourcegraph
    llm-agents.claude-code # Claude Code - Agentic coding in terminal
    llm-agents.codex # OpenAI Codex CLI
    llm-agents.gemini-cli # Google Gemini AI agent
    (llm-agents.kilocode-cli.overrideAttrs (old: {
      version = "1.0.13";
      src = fetchzip {
        url = "https://registry.npmjs.org/@kilocode/cli/-/cli-1.0.13.tgz";
        hash = "sha256-vo1bfdRYgbbkAUwKY1vdcb404uWIendGRhtIjEr2GEE=";
      };
      npmDeps = pkgs.fetchNpmDepsWithPackuments {
        inherit (old) src;
        name = "${old.pname}-1.0.13-npm-deps";
        hash = "sha256-I3sXuLQvnkPZAef6L+MR0Z7UbOhYxIP5qkpIEuUvHWs=";
        fetcherVersion = 2;
      };
    })) # Kilocode - open-source AI coding agent (version 1.0.13)
  ];

  # Note: Some agents are unfree (amp, claude-code, copilot-cli, etc.)
  # Make sure allowUnfree = true is set in nixpkgs config
}
