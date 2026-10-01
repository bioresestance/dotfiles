{ pkgs, ... }:

let
  vscodeSettings = import ./editors/vscode-settings.nix;

  vscodeRecentProjects = pkgs.writeShellApplication {
    name = "vscode-recent-projects";
    runtimeInputs = [
      pkgs.sqlite
      pkgs.jq
      pkgs.python3
      pkgs.coreutils
      pkgs.kdePackages.kservice
    ];
    text = builtins.readFile ./editors/vscode-recent-projects.sh;
  };
in
{
  programs.vscode = {
    enable = true;
    profiles.default = {
      # Allow VS Code to save settings; rebuilds merge in the declared values.
      mutableUserSettings = true;
      userSettings = vscodeSettings;
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
