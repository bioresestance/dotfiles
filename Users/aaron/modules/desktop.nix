{ pkgs, ... }:

let
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
    text = ''
                              #!/usr/bin/env bash
                              set -euo pipefail

                        log() { printf '[wallpaper-auto-switch] %s\n' "$*" >&2; }

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
