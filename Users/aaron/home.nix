{ pkgs, ... }:

let
  sharedEditorSettings = {
    "cmake.pinnedCommands" = [
      "workbench.action.tasks.configureTaskRunner"
      "workbench.action.tasks.runTask"
    ];
    "workbench.iconTheme" = "catppuccin-mocha";
    "workbench.colorTheme" = "Catppuccin Mocha";
    "github.copilot.enable" = {
      "*" = false;
      plaintext = false;
      markdown = false;
      scminput = false;
      nix = true;
    };
    "cmake.options.statusBarVisibility" = "compact";
    "git.confirmSync" = false;
    "git.autofetch" = true;
    "cmake.showOptionsMovedNotification" = false;
    "git.enableSmartCommit" = true;
    "editor.formatOnSave" = true;
    "nix.enableLanguageServer" = true;
    "nix.formatterPath" = "nixfmt";
    "nix.serverPath" = "nixd";
    "explorer.confirmDragAndDrop" = false;
    "window.titleBarStyle" = "custom";
    "explorer.confirmDelete" = false;
    "explorer.fileNesting.patterns" = {
      "*.ts" = "\${capture}.js";
      "*.js" = "\${capture}.js.map, \${capture}.min.js, \${capture}.d.ts";
      "*.jsx" = "\${capture}.js";
      "*.tsx" = "\${capture}.ts";
      "tsconfig.json" = "tsconfig.*.json";
      "package.json" = "package-lock.json, yarn.lock, pnpm-lock.yaml, bun.lockb";
      "*.sqlite" = "\${capture}.\${extname}-*";
      "*.db" = "\${capture}.\${extname}-*";
      "*.sqlite3" = "\${capture}.\${extname}-*";
      "*.db3" = "\${capture}.\${extname}-*";
      "*.sdb" = "\${capture}.\${extname}-*";
      "*.s3db" = "\${capture}.\${extname}-*";
    };
    "redhat.telemetry.enabled" = false;
    "python.analysis.typeCheckingMode" = "standard";
    "extensions.autoCheckUpdates" = false;
    "update.mode" = "none";
    "files.autoSave" = "afterDelay";
    "editor.fontFamily" = "'cascadia code'";
    "chat.tools.terminal.autoApprove" = {
      "git add Modules/" = {
        approve = true;
        matchCommandLine = true;
      };
      "git add" = true;
      nix = true;
      "bash -n /home/aaron/Dev/Homelab/scripts/merge-renovate-minor-patch.sh" = {
        approve = true;
        matchCommandLine = true;
      };
      gh = true;
      hugo = true;
      journalctl = true;
      modinfo = true;
      sed = true;
      rg = true;
      dmesg = true;
      nl = true;
      mkdir = true;
      cp = true;
      diff = true;
      lsusb = true;
      lsmod = true;
      "ansible-playbook" = true;
      ip = true;
      nmcli = true;
      "nixos-rebuild" = true;
      coredumpctl = true;
      "true" = true;
      cmake = true;
      "./build/day-12/day-12" = true;
      timeout = true;
      awk = true;
      ctest = true;
      "./test/osal_tests" = true;
      gdb = true;
      uname = true;
      lspci = true;
      sysctl = true;
      systemctl = true;
    };
    "diffEditor.ignoreTrimWhitespace" = false;
    "extensions.ignoreRecommendations" = true;
    "chat.agent.maxRequests" = 100;
    "editor.codeLensFontFamily" = "'cascadia code'";
    "editor.inlayHints.fontFamily" = "'cascadia code'";
    "editor.inlineSuggest.fontFamily" = "'cascadia code'";
    "debug.console.fontFamily" = "'cascadia code'";
    "scm.inputFontFamily" = "'cascadia code'";
    "terminal.integrated.fontFamily" = "'cascadia code'";
    "chat.editor.fontFamily" = "'cascadia code'";
    "chat.fontFamily" = "'cascadia code'";
    "terminal.integrated.fontLigatures.enabled" = true;
    "terminal.integrated.mouseWheelZoom" = true;
    "chat.mcp.gallery.enabled" = true;
    "github.copilot.nextEditSuggestions.enabled" = true;
    "chat.tools.urls.autoApprove" = {
      "https://raw.githubusercontent.com" = {
        approveRequest = false;
        approveResponse = true;
      };
      "https://api.github.com" = {
        approveRequest = false;
        approveResponse = true;
      };
    };
    "chat.viewSessions.orientation" = "stacked";
    "security.workspace.trust.untrustedFiles" = "open";
    "terminal.integrated.initialHint" = false;
  };

  cursorEditorSettings = sharedEditorSettings // {
    "cursor.cpp.disabledLanguages" = [
      "plaintext"
      "markdown"
      "scminput"
    ];
  };

  marketplaceEditorExtensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      publisher = "alphabotsec";
      name = "vscode-eclipse-keybindings";
      version = "0.16.1";
      sha256 = "sha256-VK4OS7fvpJsHracfHdC7blvh6qV0IJse4vdRud/yT/o=";
    }
    {
      publisher = "qwtel";
      name = "sqlite-viewer";
      version = "0.10.6";
      sha256 = "sha256-dN8uW1VMlaDZn2RGxerlpCil/l4FNKE3ZOp2PSV4pY0=";
    }
  ];

  sharedEditorExtensions =
    (with pkgs.vscode-extensions; [
      bradlc.vscode-tailwindcss
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      github.codespaces
      jnoortheen.nix-ide
      mechatroner.rainbow-csv
      ms-azuretools.vscode-containers
      ms-python.debugpy
      ms-python.python
      ms-python.vscode-pylance
      ms-vscode-remote.remote-containers
      ms-vscode-remote.remote-ssh
      ms-vscode-remote.remote-ssh-edit
      ms-vscode.cpptools
      ms-vscode.remote-explorer
      platformio.platformio-vscode-ide
      redhat.ansible
      redhat.vscode-yaml
      samuelcolvin.jinjahtml
      tailscale.vscode-tailscale
      tamasfe.even-better-toml
    ])
    ++ marketplaceEditorExtensions;

  rofiCatppuccinTheme = builtins.toFile "rofi-catppuccin-mocha.rasi" ''
    /* Catppuccin Mocha inspired theme */
    * {
      font: "Cascadia Code 12";
      background: #1e1e2e;
      background-alt: #181825;
      foreground: #cdd6f4;
      foreground-alt: #bac2de;
      highlight: #313244;
      accent: #89b4fa;
      accent-alt: #b4befe;
      urgent: #f38ba8;
    }

    window {
      width: 40%;
      border: 2px;
      border-radius: 12px;
      padding: 20px;
      background-color: @background;
      border-color: @accent;
    }

    mainbox {
      background-color: transparent;
      spacing: 12px;
      children: [ inputbar, listview ];
    }

    inputbar {
      background-color: transparent;
      spacing: 8px;
    }

    prompt,
    entry {
      padding: 8px 12px;
      border-radius: 8px;
      background-color: @highlight;
      text-color: @foreground;
    }

    listview {
      background-color: transparent;
      lines: 8;
      columns: 1;
      spacing: 6px;
      scrollbar: false;
    }

    element {
      padding: 8px 12px;
      border-radius: 6px;
    }

    element normal.normal {
      background-color: transparent;
      text-color: @foreground;
    }

    element alternate.normal {
      background-color: transparent;
      text-color: @foreground-alt;
    }

    element selected.normal {
      background-color: @accent;
      text-color: #1e1e2e;
    }

    element urgent.normal {
      background-color: @urgent;
      text-color: #1e1e2e;
    }
  '';

  vscodeRecentProjects = pkgs.writeShellApplication {
    name = "vscode-recent-projects";
    runtimeInputs = [
      pkgs.sqlite
      pkgs.jq
      pkgs.python3
      pkgs.coreutils
    ];
    text = ''
            DB="$HOME/.config/Code/User/globalStorage/state.vscdb"
            OUTPUT="$HOME/.local/share/applications/code.desktop"
            MAX_ENTRIES=10

            if [[ ! -f "$DB" ]]; then
              echo "VS Code state database not found, skipping" >&2
              exit 0
            fi

            mkdir -p "$(dirname "$OUTPUT")"

            # Extract recent local folders from VS Code's SQLite database
            json=$(sqlite3 "$DB" "SELECT value FROM ItemTable WHERE key = 'history.recentlyOpenedPathsList';")

            # Build action IDs and sections
            action_ids=""
            action_sections=""
            i=0

            while IFS= read -r uri; do
              [[ -z "$uri" ]] && continue

              # Decode file:// URI to filesystem path
              path=$(python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(urllib.parse.urlparse(sys.argv[1]).path))" "$uri")

              # Skip if directory doesn't exist
              [[ ! -d "$path" ]] && continue

              name=$(basename "$path")
              action_id="recent-$i"

              if [[ -n "$action_ids" ]]; then
                action_ids="$action_ids;$action_id"
              else
                action_ids="$action_id"
              fi

              action_sections="$action_sections
      [Desktop Action $action_id]
      Exec=code \"$path\"
      Icon=folder-vscode
      Name=$name
      "
              i=$((i + 1))
            done < <(echo "$json" | jq -r '.entries[] | select(.folderUri != null) | select(.folderUri | startswith("file://")) | .folderUri' | head -n "$MAX_ENTRIES")

            # Write the desktop file
            cat > "$OUTPUT" << EOF
      [Desktop Entry]
      Actions=new-empty-window;$action_ids
      Categories=Utility;TextEditor;Development;IDE
      Comment=Code Editing. Redefined.
      Exec=code %F
      GenericName=Text Editor
      Icon=vscode
      Keywords=vscode
      Name=Visual Studio Code
      StartupNotify=true
      StartupWMClass=Code
      Type=Application
      Version=1.5

      [Desktop Action new-empty-window]
      Exec=code --new-window %F
      Icon=vscode
      Name=New Empty Window
      $action_sections
      EOF

            echo "Updated VS Code desktop file with $i recent projects"
    '';
  };

  autoWallpaperSwitch = pkgs.writeShellApplication {
    name = "wallpaper-auto-switch";
    runtimeInputs = [
      pkgs.kdePackages.plasma-workspace # provides kscreen-doctor
      pkgs.qt6.qttools # qdbus
      pkgs.gawk
      pkgs.coreutils
      pkgs.bc
      pkgs.jq
    ];
    text = ''
                              #!/usr/bin/env bash
                              set -euo pipefail

                        log() { printf '[wallpaper-auto-switch] %s\n' "$*" >&2; }

                              # Wait for a Wayland (or X11) session to be available before invoking
                              # Qt-based tools like kscreen-doctor; otherwise Qt aborts in
                              # init_platform when no QPA platform can be initialized.
                              wait_for_session() {
                                local tries=0
                                while [[ -z "''${WAYLAND_DISPLAY:-}" && -z "''${DISPLAY:-}" ]]; do
                                  if (( tries >= 60 )); then
                                    log "No WAYLAND_DISPLAY/DISPLAY after 60s; exiting to let systemd retry"
                                    exit 0
                                  fi
                                  sleep 1
                                  tries=$((tries + 1))
                                done
                              }
                              wait_for_session

                              NORMAL_DIR="/home/aaron/Pictures/Wallpaper"
                              WIDE_DIR="/home/aaron/Pictures/Wallpaper-Widescreen"
                              THRESHOLD=2.4
                              last_folder=""

                              get_max_aspect() {
                                # Parse Geometry lines, which include the effective mode (post-scale) as WxH
                                kscreen-doctor -o | awk '
                                  BEGIN { max = 0 }
                                  /Geometry:/ {
                                    if (match($0, / ([0-9]+)x([0-9]+)/, a)) {
                                      w = a[1]; h = a[2];
                                      if (h > 0) {
                                        r = w / h;
                                        if (r > max) max = r;
                                      }
                                    }
                                  }
                                  END {
                                    if (max == 0) {
                                      print "0";
                                    } else {
                                      printf "%.3f", max;
                                    }
                                  }
                                '
                              }

                              choose_folder() {
                                max_ratio=$(get_max_aspect)
                                if [[ "''${max_ratio}" == "0" ]]; then
                                  log "No connected screen ratios detected; skipping"
                                  echo ""; return
                                fi
                                if echo "''${max_ratio} > ''${THRESHOLD}" | bc -l >/dev/null 2>&1; then
                                  log "Detected max aspect ''${max_ratio} > ''${THRESHOLD}; choosing WIDE"
                                  echo "''${WIDE_DIR}"
                                else
                                  log "Detected max aspect ''${max_ratio} <= ''${THRESHOLD}; choosing NORMAL"
                                  echo "''${NORMAL_DIR}"
                                fi
                              }

                              set_wallpaper() {
                                local folder="$1"
                                [[ -z "''${folder}" ]] && { log "Folder empty; skipping"; return 0; }
                                # Wait for plasmashell to be ready
                                if ! qdbus org.kde.plasmashell >/dev/null 2>&1; then
                                  log "plasmashell not ready; will retry"
                                  return 0
                                fi

                                local js
                                local escaped_folder
                                escaped_folder=$(printf '%s' "''${folder}" | sed 's/"/\\"/g')
                                js='const folder = "'"''${escaped_folder}"'";
      const desktopsList = desktops();
      for (let i = 0; i < desktopsList.length; i++) {
        const d = desktopsList[i];
        d.currentConfigGroup = ["Wallpaper", "org.kde.slideshow", "General"];
        d.writeConfig("SlidePaths", folder);
        d.writeConfig("Randomize", true);
        d.writeConfig("Interval", 600);
        d.currentConfigGroup = ["Wallpaper"];
        d.writeConfig("plugin", "org.kde.slideshow");
      }'
                                log "Applying folder ''${folder} to Plasma"
                                log "JS payload: $js"
                                qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "''${js}" || log "qdbus apply failed"
                              }

                              # Main loop: adjust when the max aspect ratio crosses the threshold
                              while true; do
                                folder=$(choose_folder)
                                if [[ -n "''${folder}" && "''${folder}" != "''${last_folder}" ]]; then
                                  set_wallpaper "''${folder}" && last_folder="''${folder}"
                                fi
                                sleep 20
                              done
    '';
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "aaron";
  home.homeDirectory = "/home/aaron";
  home.stateVersion = "24.11"; # Please read the comment before changing.

  # Allow unfree packages in home-manager
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      celeste = prev.celeste.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [ ./patches/celeste-let-chains.patch ];
      });
      remarkable = prev.callPackage ./packages/remarkable.nix { };
      spec-kit = prev.callPackage ./packages/spec-kit.nix { };
    })
  ];

  home.packages = with pkgs; [
    # Shell and Terminal
    eza
    cmatrix
    cowsay
    oh-my-zsh
    fastfetch
    kitty-themes
    cascadia-code
    zsh-autosuggestions
    oh-my-posh
    usbutils
    wakeonlan
    transmission_4
    pandoc

    # Desktop Applications
    google-chrome
    vivaldi
    discord
    thunderbird
    zoom-us
    celeste
    moonlight-qt
    obsidian
    remarkable

    # Media and Creative
    vlc
    plexamp
    gimp
    kicad
    # freecad-wayland # TODO: Disabled — fails to build with Boost 1.89 (missing boost_system cmake config)
    cheese

    # Office and Productivity
    libreoffice
    stirling-pdf

    # File Management and Transfer
    filezilla

    # Development
    hugo
    spec-kit
    cursor-cli

    # KDE Applications
    kdePackages.okular
    kdePackages.kate
  ];

  home.file = {
    ".config/1Password/ssh/agent.toml" = {
      enable = true;
      text = ''
        [[ssh-keys]]
        vault = "Development"
      '';
    };
  };

  home.sessionVariables = {
  };

  home.shellAliases = {
    ll = "ls -l";
    ".." = "cd ..";
    home-rebuild = "home-manager switch --flake /home/aaron/.dotfiles";
    ls = "eza -l";
  };

  programs.vscode = {
    enable = true;
    mutableExtensionsDir = true;
    profiles.default = {
      userSettings = sharedEditorSettings;
      extensions = sharedEditorExtensions;
    };
  };

  programs.cursor = {
    enable = true;
    mutableExtensionsDir = true;
    profiles.default = {
      userSettings = cursorEditorSettings;
      extensions = sharedEditorExtensions;
    };
  };

  programs.bash = {
    enable = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Aaron Bromma";
        email = "aaron@bromma.dev";
      };
      init.defaultBranch = "main";
      core.hooksPath = ".githooks";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      # Use the 1Password SSH agent for all hosts.
      "*" = {
        identityAgent = "~/.1password/agent.sock";
      };
    };
  };

  programs.tmux = {
    enable = true;
    mouse = true;
    newSession = true;
  };

  ################################# Shell Configs #################################

  # Use the Catppuccin Mocha theme for Zsh syntax highlighting.
  home.file.".config/zsh/catppuccin_zsh-syntax-highlighting.zsh".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/catppuccin/zsh-syntax-highlighting/main/themes/catppuccin_mocha-zsh-syntax-highlighting.zsh";
    sha256 = "1x2105vl3iiym9a5b6zsclglff4xy3r4iddz53dnns7djy6cf21d";
  };

  # ZSH configuration.
  programs.zsh = {
    enable = true;
    initContent = ''
      source ~/.config/zsh/catppuccin_zsh-syntax-highlighting.zsh
      fastfetch

      nix-rebuild() {
        local flake="/home/aaron/.dotfiles"
        local subcommand="''${1:-switch}"
        local errors=0

        echo "==> Updating flake inputs..."
        if ! nix flake update --flake "$flake"; then
          echo "ERROR: Flake update failed. Aborting."
          return 1
        fi

        echo ""
        echo "==> Formatting Nix files..."
        if (cd "$flake" && ./scripts/format.sh); then
          echo "Lint cleanup succeeded."
        else
          echo "WARNING: Lint cleanup failed; continuing."
        fi

        echo ""
        echo "==> Committing and pushing flake changes..."
        if [[ -d "$flake/.git" ]]; then
          (
            cd "$flake" || exit 1
            # Detect changes that existed before this run (i.e. untracked or
            # modifications not produced by the flake update / formatter).
            # We do this by checking whether anything other than flake.lock
            # and *.nix files is dirty.
            local preexisting
            preexisting=$(git status --porcelain | awk '{ print $2 }' \
              | grep -Ev '^(flake\.lock|.*\.nix)$' || true)
            if [[ -n "$preexisting" ]]; then
              echo "WARNING: Repository has pre-existing changes; skipping git commit/push:"
              echo "$preexisting" | sed 's/^/  - /'
              exit 0
            fi

            if git diff --quiet && git diff --cached --quiet; then
              echo "No flake changes to commit."
              exit 0
            fi

            if ! git add -A; then
              echo "WARNING: git add failed; skipping commit/push."
              exit 0
            fi
            if ! git commit -m "Updated flake"; then
              echo "WARNING: git commit failed; skipping push."
              exit 0
            fi
            if ! git push; then
              echo "WARNING: git push failed; continuing."
              exit 0
            fi
            echo "Git commit/push succeeded."
          )
        else
          echo "WARNING: $flake is not a git repository; skipping commit/push."
        fi

        echo ""
        echo "==> Rebuilding NixOS system ($subcommand)..."
        if sudo nixos-rebuild "$subcommand" --flake "$flake"; then
          echo "NixOS rebuild succeeded."
        else
          echo "ERROR: NixOS rebuild failed."
          errors=$((errors + 1))
        fi

        if [[ "$subcommand" == "switch" ]]; then
          echo ""
          echo "==> Rebuilding home-manager..."
          if home-manager switch --flake "$flake"; then
            echo "Home-manager rebuild succeeded."
          else
            echo "ERROR: Home-manager rebuild failed."
            errors=$((errors + 1))
          fi
        else
          echo ""
          echo "==> Skipping home-manager (subcommand is '$subcommand', not 'switch')."
        fi

        echo ""
        if [[ $errors -eq 0 ]]; then
          echo "All rebuilds completed successfully."
        else
          echo "$errors rebuild(s) failed."
          return 1
        fi
      }
    '';
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    history.size = 10000;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "docker-compose"
        "z"
      ];
    };
  };

  programs.kitty = {
    enable = true;
    shellIntegration.enableZshIntegration = true;
    font = {
      size = 12;
      name = "Cascadia Code";
    };
    themeFile = "Catppuccin-Mocha";
    settings = {
      background_opacity = 0.9;
      window_background_opacity = 0.9;
      scrollback_lines = 10000;
      enable_audio_bell = false;
      update_check_interval = 0;
      confirm_os_window_close = 0;
    };
  };

  programs.oh-my-posh = {
    enable = true;
    useTheme = "catppuccin";
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        type = "builtin";
        height = 15;
        width = 30;
        padding = {
          top = 5;
          left = 3;
        };
      };

      modules = [
        "break"
        {
          type = "custom";
          format = "┌──────────────────────Hardware──────────────────────┐";
        }
        {
          type = "host";
          key = " PC";
          keyColor = "green";
        }
        {
          type = "cpu";
          key = "│ ├";
          keyColor = "green";
        }
        {
          type = "gpu";
          key = "│ ├󰍛";
          keyColor = "green";
        }
        {
          type = "memory";
          key = "│ ├󰍛";
          keyColor = "green";
        }
        {
          type = "disk";
          key = "└ └";
          keyColor = "green";
        }
        {
          type = "custom";
          format = "└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌──────────────────────Software──────────────────────┐";
        }
        {
          type = "os";
          key = " OS";
          keyColor = "yellow";
        }
        {
          type = "kernel";
          key = "│ ├";
          keyColor = "yellow";
        }
        {
          type = "bios";
          key = "│ ├";
          keyColor = "yellow";
        }
        {
          type = "packages";
          key = "│ ├󰏖";
          keyColor = "yellow";
        }
        {
          type = "shell";
          key = "└ └";
          keyColor = "yellow";
        }
        "break"
        {
          type = "de";
          key = " DE";
          keyColor = "blue";
        }
        {
          type = "lm";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "wm";
          key = "│ ├";
          keyColor = "blue";
        }
        {
          type = "wmtheme";
          key = "│ ├󰉼";
          keyColor = "blue";
        }
        {
          type = "terminal";
          key = "└ └";
          keyColor = "blue";
        }
        {
          type = "custom";
          format = "└────────────────────────────────────────────────────┘";
        }
        "break"
        {
          type = "custom";
          format = "┌────────────────────Uptime / Age / DT────────────────────┐";
        }
        {
          type = "command";
          key = "  OS Age ";
          keyColor = "magenta";
          text = ''
            birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days
          '';
        }
        {
          type = "uptime";
          key = "  Uptime ";
          keyColor = "magenta";
        }
        {
          type = "datetime";
          key = "  DateTime ";
          keyColor = "magenta";
        }
        {
          type = "custom";
          format = "└─────────────────────────────────────────────────────────┘";
        }
        "break"
      ];
    };
  };

  programs.rofi = {
    enable = true;
    theme = rofiCatppuccinTheme;
  };

  # Update VS Code desktop file with recent projects for KDE jump list
  systemd.user.services.vscode-recent-projects = {
    Unit = {
      Description = "Update VS Code desktop entry with recent projects";
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${vscodeRecentProjects}/bin/vscode-recent-projects";
    };
  };

  systemd.user.timers.vscode-recent-projects = {
    Unit = {
      Description = "Periodically update VS Code recent projects jump list";
    };
    Timer = {
      OnStartupSec = "10s";
      OnUnitActiveSec = "5m";
    };
    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  # Auto-switch wallpaper folders between laptop (16:10) and ultrawide (32:9)
  systemd.user.services.wallpaper-auto-switch = {
    Unit = {
      Description = "Auto-select Plasma wallpaper folder based on screen aspect ratio";
      After = [ "graphical-session.target" ];
      Requisite = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${autoWallpaperSwitch}/bin/wallpaper-auto-switch";
      Restart = "on-failure";
      RestartSec = 10;
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  #################################################################################

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
