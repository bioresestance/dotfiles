#!/usr/bin/env bash
set -euo pipefail

OUTPUT="$HOME/.local/share/applications/code.desktop"
MAX_ENTRIES=10
STORAGE="$HOME/.config/Code/User/globalStorage/storage.json"
WORKSPACE_STORAGE="$HOME/.config/Code/User/workspaceStorage"

declare -a entries=()
declare -A seen_paths=()

decode_file_uri() {
  python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(urllib.parse.urlparse(sys.argv[1]).path))" "$1"
}

add_uri() {
  local uri="$1"
  local path

  [[ -n "$uri" ]] || return 0
  [[ "$uri" == file://* ]] || return 0

  path=$(decode_file_uri "$uri")
  [[ -n "$path" ]] || return 0
  [[ -d "$path" || -f "$path" ]] || return 0
  [[ "$path" != /nix/store/* ]] || return 0
  [[ "$path" != "$HOME"/.config/Code/Workspaces/* ]] || return 0
  [[ "$path" != "$HOME"/.config/Code/User/agent-sessions.code-workspace ]] || return 0

  if [[ -n "${seen_paths[$path]+x}" ]]; then
    return 0
  fi

  seen_paths["$path"]=1
  entries+=("$path")
}

add_uris_from_jq() {
  local source="$1"
  local filter="$2"

  [[ -f "$source" ]] || return 0

  while IFS= read -r uri; do
    add_uri "$uri"
  done < <(jq -r "$filter" "$source" 2>/dev/null || true)
}

add_uris_from_legacy_state() {
  local db="$1"
  local json

  [[ -f "$db" ]] || return 0

  json=$(sqlite3 "$db" "SELECT value FROM ItemTable WHERE key = 'history.recentlyOpenedPathsList';" 2>/dev/null || true)
  [[ -n "$json" ]] || return 0

  while IFS= read -r uri; do
    add_uri "$uri"
  done < <(
    echo "$json" | jq -r '
      def as_uri:
        if type == "string" then .
        elif type == "object" then (.external? // (if .scheme? == "file" and .path? then "file://" + .path else empty end))
        else empty
        end;

      .entries[]? |
        (.folderUri? // .workspace?.configPath? // .workspaceUri? // .fileUri? // empty) |
        as_uri
    ' 2>/dev/null || true
  )
}

add_uris_from_agent_profiles() {
  local db="$1"
  local json

  [[ -f "$db" ]] || return 0

  json=$(sqlite3 "$db" "SELECT value FROM ItemTable WHERE key = 'sessions.recentlyPickedWorkspaces';" 2>/dev/null || true)
  [[ -n "$json" ]] || return 0

  while IFS= read -r uri; do
    add_uri "$uri"
  done < <(
    echo "$json" | jq -r '
      .[]? |
        .uri? |
        if type == "string" then .
        elif type == "object" then (.external? // (if .scheme? == "file" and .path? then "file://" + .path else empty end))
        else empty
        end
    ' 2>/dev/null || true
  )
}

mkdir -p "$(dirname "$OUTPUT")"

add_uris_from_jq "$STORAGE" '
  .windowsState.lastActiveWindow.folder? // empty,
  .backupWorkspaces.folders[]?.folderUri? // empty
'

if [[ -d "$WORKSPACE_STORAGE" ]]; then
  while IFS= read -r uri; do
    add_uri "$uri"
  done < <(
    for workspace_file in "$WORKSPACE_STORAGE"/*/workspace.json; do
      [[ -f "$workspace_file" ]] || continue
      uri=$(jq -r '.folder // .workspace // .configuration // empty' "$workspace_file" 2>/dev/null || true)
      [[ -n "$uri" ]] || continue
      printf '%s\t%s\n' "$(stat -c '%Y' "$workspace_file")" "$uri"
    done | sort -rn | cut -f2-
  )
fi

for db in "$HOME"/.config/Code/User/globalStorage/state.vscdb "$HOME"/.config/Code/User/profiles/*/globalStorage/state.vscdb; do
  add_uris_from_legacy_state "$db"
  add_uris_from_agent_profiles "$db"
done

add_uris_from_jq "$STORAGE" '
  .profileAssociations.workspaces? | keys[]?
'

action_ids=""
action_sections=""
i=0

for path in "${entries[@]}"; do
  if [[ $i -ge $MAX_ENTRIES ]]; then
    break
  fi

  safe_path=${path//\\/\\\\}
  safe_path=${safe_path//\"/\\\"}
  name=$(basename "$path")
  name=${name//$'\n'/ }
  action_id="recent-$i"

  action_ids="$action_ids$action_id;"

  action_sections="$action_sections
[Desktop Action $action_id]
Exec=code \"$safe_path\"
Icon=folder-vscode
Name=$name
"
  i=$((i + 1))
done

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

kbuildsycoca6 --noincremental >/dev/null 2>&1 || true

echo "Updated VS Code desktop file with $i recent projects"
