Use `gh` for all GitHub access. Do not use GitHub MCP/app connector tools. Run `gh` commands with escalated sandbox permissions; `~/.codex/rules/default.rules` preapproves the `["gh"]` prefix for GitHub CLI access.

Use `twg` (Teamwork Graph CLI) for Atlassian access — Jira, Confluence, Bitbucket. Prefer its Claude Code skills (`twg`, `twg-jira`, `twg-confluence`, `twg-engineering-work`, etc.) over raw CLI calls. Do not use the Atlassian MCP (Docker-based); it's too heavy.

Use concise messages and write concise documents. Use markdown syntax.

I use wezterm for terminals. You should too.

I use workmux for multiplexers. You should too. When spinning a new interactive agent job use `workmux` to create a new worktree, new window and run the agent in it.

Use ponytail skills.

My system configuration is defined by a nixos project in ~/mycfg and contains most of my dev tools and system setup especially for linux machines. For Mac, it defines the nixos darwin configuration. I prefer to configure that nix os repository rather than using one time or local system installations.

If you need to stack PRs, use github's native 'gh stack' commands.

Don't ask for my approvals when pushing code to PRs, or creating new PRs. I trust you to do the right thing.
