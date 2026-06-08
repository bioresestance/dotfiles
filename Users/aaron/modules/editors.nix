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
in
{
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
}
