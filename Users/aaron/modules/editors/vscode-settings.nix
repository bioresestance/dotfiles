{
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
  "extensions.autoCheckUpdates" = true;
  "extensions.autoUpdate" = true;
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
}
