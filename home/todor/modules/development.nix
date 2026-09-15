{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  isLinux = pkgs.stdenv.isLinux;
  isDarwin = pkgs.stdenv.isDarwin;
  llmAgentsPkgs = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  unstablePkgs = import inputs.nixpkgsUnstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = config.nixpkgs.config;
  };
  voxtypePkgs = inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system} or { };
  voxtypeOnnx = voxtypePkgs.onnx or null;
  voxtypeRuntimePath = lib.makeBinPath (
    [
      pkgs.which
    ]
    ++ lib.optionals isLinux [
      pkgs.wtype
      pkgs.wl-clipboard
      pkgs.ydotool
      pkgs.xdotool
      pkgs.xclip
      pkgs.libnotify
      pkgs.pciutils
      pkgs.dotool
    ]
  );
  voxtypePackage =
    if isLinux && voxtypeOnnx != null then
      pkgs.symlinkJoin {
        name = "voxtype-onnx-wrapped";
        paths = [ voxtypeOnnx ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/voxtype \
            --prefix PATH : ${voxtypeRuntimePath}
        '';
      }
    else if isLinux then
      llmAgentsPkgs.voxtype
    else
      null;
  skillsPackage = pkgs.symlinkJoin {
    name = "skills-wrapped";
    paths = [ llmAgentsPkgs.skills ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/skills \
        --prefix PATH : ${lib.makeBinPath [ pkgs.git ]}
    '';
  };
  orcaVersion = "1.4.203";
  orcaSources = {
    aarch64-darwin = pkgs.fetchurl {
      url = "https://github.com/stablyai/orca/releases/download/v${orcaVersion}/Orca-${orcaVersion}-arm64-mac.zip";
      hash = "sha256-ocW+tRm8JvOnJLmQ9qKaTXx4anWI5Rjygb2qY0qiDxQ=";
    };
    x86_64-darwin = pkgs.fetchurl {
      url = "https://github.com/stablyai/orca/releases/download/v${orcaVersion}/Orca-${orcaVersion}-mac.zip";
      hash = "sha256-b/fzZWMWYwPVmXcFrnEQbuPjtW6qztPCdKmO9z0c70E=";
    };
    x86_64-linux = pkgs.fetchurl {
      url = "https://github.com/stablyai/orca/releases/download/v${orcaVersion}/orca-ide_${orcaVersion}_amd64.deb";
      hash = "sha256-dRXrYSY2QInMMJSrZRJcR4rol+2XLi1fPR0vcNW4fjs=";
    };
    aarch64-linux = pkgs.fetchurl {
      url = "https://github.com/stablyai/orca/releases/download/v${orcaVersion}/orca-ide_${orcaVersion}_arm64.deb";
      hash = "sha256-FxQP6mLYcjN+q1bFUad9Qg7s38Gx+6dA22w2aeB1Pxo=";
    };
  };
  orcaSrc =
    orcaSources.${pkgs.stdenv.hostPlatform.system}
      or (throw "Orca is not packaged for ${pkgs.stdenv.hostPlatform.system}");
  orcaPackage =
    if isDarwin then
      pkgs.stdenvNoCC.mkDerivation {
        pname = "orca";
        version = orcaVersion;
        src = orcaSrc;
        dontFixup = true;
        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.unzip
        ];
        sourceRoot = ".";
        installPhase = ''
          runHook preInstall

          mkdir -p "$out/Applications" "$out/bin"
          cp -R Orca.app "$out/Applications/Orca.app"
          /usr/bin/codesign --force --deep --sign - "$out/Applications/Orca.app"
          makeWrapper /usr/bin/open "$out/bin/orca" \
            --add-flags "-n" \
            --add-flags "$out/Applications/Orca.app" \
            --add-flags "--args"

          runHook postInstall
        '';
        meta = {
          description = "Agent development environment for running coding agents in parallel";
          homepage = "https://www.onorca.dev/";
          license = lib.licenses.mit;
          mainProgram = "orca";
          platforms = [
            "aarch64-darwin"
            "x86_64-darwin"
          ];
        };
      }
    else
      pkgs.stdenv.mkDerivation {
        pname = "orca";
        version = orcaVersion;
        src = orcaSrc;
        nativeBuildInputs = [
          pkgs.autoPatchelfHook
          pkgs.dpkg
          pkgs.makeWrapper
        ];
        buildInputs = [
          pkgs.alsa-lib
          pkgs.at-spi2-atk
          pkgs.at-spi2-core
          pkgs.cairo
          pkgs.cups
          pkgs.dbus
          pkgs.expat
          pkgs.glib
          pkgs.gtk3
          pkgs.libdrm
          pkgs.libgbm
          pkgs.libxkbcommon
          pkgs.mesa
          pkgs.nss
          pkgs.pango
          pkgs.xorg.libX11
          pkgs.xorg.libxcb
          pkgs.xorg.libXcomposite
          pkgs.xorg.libXdamage
          pkgs.xorg.libXext
          pkgs.xorg.libXfixes
          pkgs.xorg.libXrandr
        ];
        installPhase = ''
          runHook preInstall

          mkdir -p "$out/bin" "$out/opt"
          cp -R usr/* "$out"
          cp -R opt/* "$out/opt"
          wrapProgram "$out/opt/Orca/orca-ide" "$out/bin/orca"
          substituteInPlace "$out/share/applications/orca-ide.desktop" \
            --replace-fail "/opt/Orca/orca-ide" "orca"

          runHook postInstall
        '';
        meta = {
          description = "Agent development environment for running coding agents in parallel";
          homepage = "https://www.onorca.dev/";
          license = lib.licenses.mit;
          mainProgram = "orca";
          platforms = [
            "aarch64-linux"
            "x86_64-linux"
          ];
        };
      };
  omnigentVersion = "0.13.0";
  omnigentRuntimeInputs = [
    pkgs.git
    pkgs.nodejs
    pkgs.pnpm
    pkgs.python312
    pkgs.tmux
    pkgs.uv
  ]
  ++ lib.optionals isLinux [
    pkgs.bubblewrap
  ];
  mkOmnigentLauncher =
    name:
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = omnigentRuntimeInputs;
      text = ''
        export UV_PYTHON_DOWNLOADS=never
        exec uv tool run --from omnigent==${omnigentVersion} --python ${pkgs.python312}/bin/python3.12 ${name} "$@"
      '';
    };
  omnigentPackage = pkgs.symlinkJoin {
    name = "omnigent-${omnigentVersion}";
    paths = [
      (mkOmnigentLauncher "omnigent")
      (mkOmnigentLauncher "omni")
    ];
    meta = {
      description = "Open-source meta-harness for AI coding agents";
      homepage = "https://omnigent.ai/";
      license = lib.licenses.asl20;
      mainProgram = "omni";
      platforms = lib.platforms.darwin ++ lib.platforms.linux;
    };
  };
  # ponytail: replace these local packages if llm-agents.nix packages the tools.
  codeburnPackage = pkgs.writeShellApplication {
    name = "codeburn";
    runtimeInputs = [ pkgs.nodejs ];
    text = ''
      exec npm exec --yes --package=codeburn@0.9.20 -- codeburn "$@"
    '';
  };
  driftPackage = unstablePkgs.rustPlatform.buildRustPackage rec {
    pname = "drift";
    version = "0.22.0";
    src = unstablePkgs.fetchCrate {
      pname = "drift-tui";
      inherit version;
      hash = "sha256-TnWjmIHyGfX00LqmI4ZIJD92CY+mfPjpo2qDYjUNTes=";
    };
    cargoHash = "sha256-yjgWoYAAKBwxLYVkM9Xt3r/WFe1ws28hdYIstOErS38=";
    doCheck = false;
  };
  revdiffPackage = pkgs.writeShellApplication {
    name = "revdiff";
    runtimeInputs = [ unstablePkgs.go ];
    text = ''
      exec go run -ldflags "-X main.revision=v1.12.0" github.com/umputun/revdiff/app@v1.12.0 "$@"
    '';
  };
  workmuxConfig = (pkgs.formats.yaml { }).generate "workmux-config.yaml" {
    nerdfont = true;
    merge_strategy = "rebase";
    merge_keep = true;
    agent = "codex";
    panes = [
      {
        command = "<agent>";
        focus = true;
      }
      {
        split = "horizontal";
      }
    ];
  };
  mkCodexPrefixRule = pattern: ''prefix_rule(pattern=${builtins.toJSON pattern}, decision="allow")'';
  codexHomeManagerRules =
    lib.concatMapStringsSep "\n" mkCodexPrefixRule [
      [
        "codex"
        "mcp"
      ]
      [ "docker" ]
      [ "git" ]
      [ "gh" ]
      [ "curl" ]
      [ "wget" ]
      [ "jq" ]
      [ "rg" ]
      [ "fd" ]
      [ "fzf" ]
      [ "tree" ]
      [ "eza" ]
      [ "dysk" ]
      [ "dua" ]
      [ "dig" ]
      [ "host" ]
      [ "nslookup" ]
      [ "whois" ]
      [
        "nix"
        "eval"
      ]
      [
        "nix"
        "flake"
        "check"
        "--no-build"
      ]
      [
        "nix-instantiate"
        "--parse"
      ]
      [ "nixfmt" ]
      [ "nixfmt-rfc-style" ]
      [ "nixfmt-tree" ]
      [ "statix" ]
    ]
    + "\n";
  # Note: mattpocock/skills, DietrichGebert/ponytail, and tt-a1i/archify are
  # installed via the `skills` CLI (see home/todor/modules/agents.nix), not
  # vendored here.
  understandAnythingSkillPaths = [
    "skills/understand"
    "skills/understand-chat"
    "skills/understand-dashboard"
    "skills/understand-diff"
    "skills/understand-domain"
    "skills/understand-explain"
    "skills/understand-figma"
    "skills/understand-knowledge"
    "skills/understand-onboard"
  ];
  graphifySkill = pkgs.runCommandLocal "graphify-skill" { } ''
    mkdir -p "$out/graphify"
    cp ${inputs.graphify-skills}/graphify/skill.md "$out/graphify/SKILL.md"
  '';
  understandAnythingPlugin = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "understand-anything-plugin";
    version = "2.9.4";
    src = inputs.understand-anything + "/understand-anything-plugin";

    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.pnpm.configHook
      pkgs.pnpm
    ];

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      pnpm = pkgs.pnpm;
      fetcherVersion = 3;
      hash = "sha256-Zq6rdL+DJ3J9fm5yNPtHPygHTfIbOSLaX3M5emat+RY=";
    };

    buildPhase = ''
      runHook preBuild
      pnpm --filter @understand-anything/core build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R . "$out/"
      runHook postInstall
    '';
  });
  mkAgentSkillLinks =
    source: paths:
    lib.listToAttrs (
      map (
        path:
        let
          name = builtins.baseNameOf path;
        in
        {
          name = ".agents/skills/${name}";
          value.source = source + "/${path}";
        }
      ) paths
    );
  understandAnythingSkillLinks = mkAgentSkillLinks understandAnythingPlugin understandAnythingSkillPaths;
  graphifySkillLinks = {
    ".agents/skills/graphify".source = graphifySkill + "/graphify";
  };
in
{
  # Development tools and environment
  home.packages =
    with pkgs;
    [
      # shell productivity (cross-platform)
      devenv
      nil
      gopass
      nixd
      statix # Nix linter and code suggestions
      zed-editor
      warp-terminal
      amp-cli
      codeburnPackage
      driftPackage
      revdiffPackage
      llmAgentsPkgs.kilocode-cli
      llmAgentsPkgs.codex
      llmAgentsPkgs.claude-code
      llmAgentsPkgs.agent-browser
      llmAgentsPkgs.hunk
      llmAgentsPkgs.but
      skillsPackage
      orcaPackage
      omnigentPackage
      llmAgentsPkgs.openspec
      llmAgentsPkgs.openspecui
      llmAgentsPkgs.fence
      llmAgentsPkgs.workmux
      llmAgentsPkgs.herdr
      llmAgentsPkgs.rtk
      llmAgentsPkgs.gastown
      llmAgentsPkgs.beads
      llmAgentsPkgs.beads-viewer
      llmAgentsPkgs.mardi-gras
      llmAgentsPkgs.omp
      llmAgentsPkgs.pi
      jq # for jsontools plugin
      unstablePkgs.neovim # Neovim 0.12 until it lands in the 25.11 branch
      jiratui

      # Neovim/LazyVim dependencies (cross-platform)
      tree-sitter # Tree-sitter CLI
      ripgrep # Fast grep for telescope
      fd # Fast find for telescope
      fzf # Fuzzy finder
      unzip # For Mason package extraction
      (python3.withPackages (
        ps: with ps; [
          pip
        ]
      )) # Python with pip
      uv # Fast Python package installer and resolver
      wget # For downloading packages
      curl # For downloading packages

      # Zig development (cross-platform)
      zig
      zls

      # Go development (cross-platform)
      go
      gopls
      gotools

      # ops (cross-platform)
      flyctl # Fly.io CLI
      awscli2 # for aws plugin
      kubectl # for kubectl plugin
      bun # for bun plugin
      nodejs # for npm plugin
      pnpm # for Understand Anything skill fallbacks
      nodePackages.typescript-language-server # TypeScript LSP

      # Rust development (cross-platform)
      rustc
      cargo
      rust-analyzer
      rustfmt
      clippy

      # PHP development (cross-platform)
      php
      phpactor

      # BEAM development (cross-platform)
      erlang_28
      beam28Packages.elixir_1_19

      # PHP development (cross-platform)
      php
      phpactor

      # BEAM development (cross-platform)
      erlang_28
      beam28Packages.elixir_1_19

      # Lua development (for Neovim config, cross-platform)
      lua-language-server

      # Build tools (cross-platform)
      gnumake
      git
      gh
      lazygit
      delta
      git-town
      # Docker and container tools (cross-platform)
      docker_29
      docker-compose
      lazydocker # TUI Docker client
    ]
    ++ lib.optional (voxtypePackage != null) voxtypePackage
    ++ lib.optionals isLinux [
      # Linux-only packages
      pinentry-bemenu # Wayland-native pinentry for gopass/age
      pinentry-gnome3 # GUI pinentry for gopass/age (Linux only)
      gcc # C compiler for treesitter (macOS has clang by default)
      zenity # Askpass helper for sudo (used by Claude Code)
      bluetuith # TUI Bluetooth manager (Linux only)
    ];

  programs = {
    # Version control
    git = {
      enable = true;
      settings = {
        user = {
          name = "Todor Todorov";
          email = "98095+tptodorov@users.noreply.github.com";
        };
      };
    };

    lazygit = {
      enable = true;
      settings = {
        gui = {
          showRandomTip = false;
        };
        git = {
          branchPrefix = "todor/";
          # Disable auto-fetch on startup and periodically - it blocks keyboard input
          autoFetch = false;
          # Keep auto-refresh enabled but increase interval to reduce startup blocking
          autoRefresh = true;
          fetchAll = false;
          pagers = [
            {
              name = "delta";
              colorArg = "always";
              pager = "delta --dark --paging=never";
            }
          ];
        };
        customCommands = [
          {
            key = "Y";
            context = "global";
            description = "Git Town sYnc";
            command = "git town sync --all";
            loadingText = "Syncing";
            output = "log";
          }
          {
            key = "V";
            context = "files";
            description = "View selected file with v()";
            command = "v {{.SelectedFile.Name | quote}}";
            output = "terminal";
          }
          {
            key = "U";
            context = "global";
            description = "Git Town Undo (undo the last Git Town command)";
            command = "git-town undo";
            prompts = [
              {
                type = "confirm";
                title = "Undo Last Command";
                body = "Are you sure you want to Undo the last Git Town command?";
              }
            ];
            loadingText = "Undoing Git Town Command";
            output = "log";
          }
          {
            key = "!";
            context = "global";
            description = "Git Town Repo (opens the repo link)";
            command = "git-town repo";
            loadingText = "Opening Repo Link";
            output = "log";
          }
          {
            key = "a";
            context = "localBranches";
            description = "Git Town Append";
            prompts = [
              {
                type = "input";
                title = "Enter name of new child branch. Branches off of '{{.CheckedOutBranch.Name}}'";
                key = "BranchName";
                initialValue = "todor/";
              }
            ];
            command = "git-town append {{.Form.BranchName}}";
            loadingText = "Appending";
            output = "log";
          }
          {
            key = "H";
            context = "localBranches";
            description = "Git Town Hack (creates a new branch)";
            prompts = [
              {
                type = "input";
                title = "Enter name of new branch. Branches off of 'Main'";
                key = "BranchName";
                initialValue = "todor/";
              }
            ];
            command = "git-town hack {{.Form.BranchName}}";
            loadingText = "Hacking";
            output = "log";
          }
          {
            key = "I";
            context = "localBranches";
            description = "Git Town Initiate hack+propose";
            prompts = [
              {
                type = "input";
                title = "Enter name of new branch. Branches off of 'Main'";
                key = "BranchName";
                initialValue = "todor/";
              }
              {
                type = "input";
                title = "Enter Commit Message";
                key = "CommitMessage";
              }
            ];
            command = "git-town hack {{.Form.BranchName}} -m '{{.Form.CommitMessage}}' -c --propose";
            loadingText = "Hacking";
            output = "log";
          }
          {
            key = "D";
            context = "localBranches";
            description = "Git Town Delete (deletes the current feature branch and sYnc)";
            command = "git-town delete";
            prompts = [
              {
                type = "confirm";
                title = "Delete current feature branch";
                body = "Are you sure you want to delete the current feature branch?";
              }
            ];
            loadingText = "Deleting Feature Branch";
            output = "log";
          }
          {
            key = "g";
            context = "localBranches";
            description = "Git Town Propose (creates a pull request)";
            command = "git-town propose";
            loadingText = "Creating pull request";
            output = "log";
          }
          {
            key = "b";
            context = "localBranches";
            description = "Git Town Prepend (creates a branch before/between current and parent)";
            prompts = [
              {
                type = "input";
                title = "Enter name of the for child branch between '{{.CheckedOutBranch.Name}}' and its parent";
                key = "BranchName";
              }
            ];
            command = "git-town prepend {{.Form.BranchName}}";
            loadingText = "Prepending";
            output = "log";
          }
          {
            key = "S";
            context = "localBranches";
            description = "Git Town Skip (skip branch with merge conflicts when syncing)";
            command = "git-town skip";
            loadingText = "Skiping";
            output = "log";
          }
          {
            key = "G";
            context = "files";
            description = "Git Town GO Continue (continue after resolving merge conflicts)";
            command = "git-town continue";
            loadingText = "Continuing";
            output = "log";
          }
          {
            key = "E";
            context = "localBranches";
            description = "Git Town Compress";
            command = "git-town compress";
            loadingText = "Compressing";
            output = "log";
          }
        ];
      };
    };

    # Development environment
    direnv = {
      enable = true;
      # Without this, direnv's stock `use flake` shells out to
      # `nix print-dev-env` on every cd into a flake repo (~0.6s warm, ~4.2s
      # whenever a tracked file changed, since a git+file: flake's tree hash
      # invalidates Nix's eval cache). nix-direnv caches the evaluated dev env
      # in .direnv/ keyed on flake.nix/flake.lock, so editing source files
      # never invalidates it -- measured ~0.35s and flat.
      nix-direnv.enable = true;
    };

  };

  xdg.configFile."workmux/config.yaml".source = workmuxConfig;

  # File configurations
  home.file = {
    # Neovim LazyVim configuration
    ".config/nvim".source = ../config/nvim;

    # Zed Editor settings file
    ".config/zed/settings.json".source = ../config/zed/private_settings.json;

    # Codex global command approval rules managed by Home Manager.
    # Codex keeps writing user-approved commands to ~/.codex/rules/default.rules.
    ".codex/rules/home-manager.rules".text = codexHomeManagerRules;

    # Git identity for standalone mode (managed by Home Manager)
    ".config/git/config.d/identity".text = ''
      [user]
        name = Todor Todorov
        email = 98095+tptodorov@users.noreply.github.com
    '';
  }
  // understandAnythingSkillLinks
  // graphifySkillLinks
  // {
    ".understand-anything-plugin".source = understandAnythingPlugin;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
  }
  // (
    if isLinux then
      {
        # Askpass configuration for sudo (used by Claude Code) - Linux only
        SUDO_ASKPASS = "${pkgs.writeShellScript "askpass" ''
          ${pkgs.zenity}/bin/zenity --password --title="sudo password prompt"
        ''}";
      }
    else
      { }
  );

  services = {
    # Container services
    podman.enable = isLinux;
  };
}
