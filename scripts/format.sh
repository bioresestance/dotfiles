#!/usr/bin/env bash
# Format all Nix files in the repository

set -e

# Always format this repository, regardless of the caller's working directory.
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

echo "Formatting Nix files..."

# Find all .nix files excluding result directories and format them
find . -name "*.nix" -type f \
  ! -path "./.git/*" \
  ! -path "./result/*" \
  ! -path "./result-*/*" \
  -exec nixfmt {} +

echo "✓ All files formatted!"
