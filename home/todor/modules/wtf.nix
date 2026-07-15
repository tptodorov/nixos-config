{ pkgs, ... }:
let
  githubOpenPrs = pkgs.writeShellApplication {
    name = "wtf-github-open-prs";
    runtimeInputs = [
      pkgs.gh
      pkgs.jq
    ];
    text = ''
      set -euo pipefail

      limit="''${WTF_GITHUB_PR_LIMIT:-30}"
      output="$(
        gh search prs \
          --author @me \
          --state open \
          --sort updated \
          --order desc \
          --limit "$limit" \
          --json repository,title,number,updatedAt 2>&1
      )" || {
        echo "GitHub query failed"
        exit 0
      }

      printf '%s\n' "$output" | jq -r '
        if length == 0 then
          "No open PRs"
        else
          .[]
          | "\(.repository.nameWithOwner)#\(.number)\n  \(.title)\n"
        end
      '
    '';
  };

  jiraAssigned = pkgs.writeShellApplication {
    name = "wtf-jira-assigned";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
      pkgs.jq
    ];
    text = ''
      set -euo pipefail

      env_file="''${WTF_JIRA_ENV_FILE:-$HOME/redislabsdev/langcache/.env.mcp}"
      if [ ! -f "$env_file" ]; then
        echo "Missing Jira env file: $env_file"
        exit 0
      fi

      set -a
      # shellcheck disable=SC1090
      . "$env_file"
      set +a

      if [ -z "''${JIRA_URL:-}" ] || [ -z "''${JIRA_USERNAME:-}" ] || [ -z "''${JIRA_API_TOKEN:-}" ]; then
        echo "Missing JIRA_URL, JIRA_USERNAME, or JIRA_API_TOKEN"
        exit 0
      fi

      max_results="''${WTF_JIRA_MAX_RESULTS:-20}"
      jql="''${WTF_JIRA_JQL:-assignee = currentUser() AND statusCategory != Done ORDER BY updated DESC}"
      body_file="$(mktemp)"
      trap 'rm -f "$body_file"' EXIT

      status="$(
        curl \
          --silent \
          --show-error \
          --get \
          --output "$body_file" \
          --write-out '%{http_code}' \
          --user "$JIRA_USERNAME:$JIRA_API_TOKEN" \
          --header 'Accept: application/json' \
          --data-urlencode "jql=$jql" \
          --data-urlencode "maxResults=$max_results" \
          --data-urlencode 'fields=summary,status,priority,updated' \
          "''${JIRA_URL%/}/rest/api/3/search/jql"
      )" || status="000"

      if [ "$status" -lt 200 ] || [ "$status" -gt 299 ]; then
        echo "Jira query failed (HTTP $status)"
        exit 0
      fi

      jq -r '
        def clip($n):
          if length > $n then .[0:($n - 3)] + "..." else . end;

        if ((.issues // []) | length) == 0 then
          "No assigned Jira tickets"
        else
          (.issues // [])[]
          | "\(.key) [\(.fields.status.name)] \((.fields.summary // "") | clip(100))"
        end
      ' "$body_file"
    '';
  };
in
{
  home.packages = [
    pkgs.wtfutil
    githubOpenPrs
    jiraAssigned
  ];

  xdg.configFile."wtf/config.yml".text = ''
    wtf:
      colors:
        border:
          focusable: steelblue
          focused: orange
          normal: gray
        title: white
        text: white
      grid:
        columns: [58, 100]
        rows: [28]
      refreshInterval: 60
      mods:
        github_open_prs:
          args: []
          cmd: wtf-github-open-prs
          enabled: true
          focusable: true
          maxLines: 80
          position:
            top: 0
            left: 0
            height: 1
            width: 1
          refreshInterval: 5m
          title: GitHub PRs
          type: cmdrunner
        jira_assigned:
          args: []
          cmd: wtf-jira-assigned
          enabled: true
          focusable: true
          maxLines: 80
          position:
            top: 0
            left: 1
            height: 1
            width: 1
          refreshInterval: 5m
          title: Jira Tickets
          type: cmdrunner
  '';
}
