#!/usr/bin/env bash
set -euo pipefail

log() { printf '[wallpaper-auto-switch] %s\n' "$*" >&2; }

wait_for_session() {
  local tries=0
  while [[ -z "${WAYLAND_DISPLAY:-}" && -z "${DISPLAY:-}" ]]; do
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
  if [[ "${max_ratio}" == "0" ]]; then
    log "No connected screen ratios detected; skipping"
    echo ""; return
  fi
  if echo "${max_ratio} > ${THRESHOLD}" | bc -l >/dev/null 2>&1; then
    log "Detected max aspect ${max_ratio} > ${THRESHOLD}; choosing WIDE"
    echo "${WIDE_DIR}"
  else
    log "Detected max aspect ${max_ratio} <= ${THRESHOLD}; choosing NORMAL"
    echo "${NORMAL_DIR}"
  fi
}

set_wallpaper() {
  local folder="$1"
  [[ -z "${folder}" ]] && { log "Folder empty; skipping"; return 0; }
  if ! qdbus org.kde.plasmashell >/dev/null 2>&1; then
    log "plasmashell not ready; will retry"
    return 0
  fi

  local js
  local escaped_folder
  escaped_folder=$(printf '%s' "${folder}" | sed 's/"/\\"/g')
  js='const folder = "'"${escaped_folder}"'";
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
  log "Applying folder ${folder} to Plasma"
  log "JS payload: $js"
  qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "${js}" || log "qdbus apply failed"
}

while true; do
  folder=$(choose_folder)
  if [[ -n "${folder}" && "${folder}" != "${last_folder}" ]]; then
    set_wallpaper "${folder}" && last_folder="${folder}"
  fi
  sleep 20
done
