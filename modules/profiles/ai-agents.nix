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
  ];

  # Note: Some agents are unfree (amp, claude-code, copilot-cli, etc.)
  # Make sure allowUnfree = true is set in nixpkgs config

  # Kilocode CLI - install via npm (not available as Nix package due to missing lock file):
  #   npm install -g @kilocode/cli
}
