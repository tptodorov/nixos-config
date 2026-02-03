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
    llm-agents.kilocode-cli # Kilocode - open-source AI coding agent
  ];

  # Note: Some agents are unfree (amp, claude-code, copilot-cli, etc.)
  # Make sure allowUnfree = true is set in nixpkgs config
}
