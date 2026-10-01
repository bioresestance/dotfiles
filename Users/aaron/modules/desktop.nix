{ pkgs, ... }:

let
  rofiCatppuccinTheme = ./desktop/rofi-catppuccin-mocha.rasi;

  autoWallpaperSwitch = pkgs.writeShellApplication {
    name = "wallpaper-auto-switch";
    runtimeInputs = [
      pkgs.kdePackages.plasma-workspace
      pkgs.qt6.qttools
      pkgs.gawk
      pkgs.coreutils
      pkgs.bc
      pkgs.jq
    ];
    text = builtins.readFile ./desktop/wallpaper-auto-switch.sh;
  };
in
{
  programs.rofi = {
    enable = true;
    theme = rofiCatppuccinTheme;
  };

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
}
