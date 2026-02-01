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
    # Primary AI Coding Agents
    llm-agents.amp             # Amp - Agentic coding tool from Sourcegraph
    llm-agents.claude-code     # Claude Code - Agentic coding in terminal
    llm-agents.copilot-cli     # GitHub Copilot CLI
    
    # Alternative AI Agents
    llm-agents.codex           # OpenAI Codex CLI
    llm-agents.gemini-cli      # Google Gemini AI agent
    llm-agents.crush           # Charmbracelet's AI coding agent
    llm-agents.goose-cli       # Block's Goose - local AI agent
    llm-agents.kilocode-cli    # Kilocode - open-source AI coding agent
    llm-agents.mistral-vibe    # Mistral AI's coding agent
    
    # Additional Tools
    llm-agents.code            # Fork of codex with multi-provider support
    llm-agents.nanocoder       # Community-built local-first coding agent
    llm-agents.eca             # Editor Code Assistant
  ];

  # Note: Some agents are unfree (amp, claude-code, copilot-cli, etc.)
  # Make sure allowUnfree = true is set in nixpkgs config
}
