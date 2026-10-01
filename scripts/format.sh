#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

case "${1:-}" in
  "") formatter_args=() ;;
  --check) formatter_args=(--check) ;;
  *) echo "Usage: $0 [--check]" >&2; exit 2 ;;
esac

formatter=${DOTFILES_NIXFMT:-nixfmt}
nix_files=()
while IFS= read -r -d '' file; do
  [[ -f "$file" ]] && nix_files+=("$file")
done < <(git ls-files --cached --others --exclude-standard -z -- '*.nix')

if (( ${#nix_files[@]} == 0 )); then
  exit 0
fi

"$formatter" "${formatter_args[@]}" "${nix_files[@]}"
