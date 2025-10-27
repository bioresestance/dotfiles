#!/usr/bin/env bash
# Format all Nix files in the repository

set -e

echo "Formatting Nix files..."

# Find all .nix files excluding result directories and format them
find . -name "*.nix" -type f \
  ! -path "./.git/*" \
  ! -path "./result/*" \
  ! -path "./result-*/*" \
  -exec nixfmt {} +

echo "✓ All files formatted!"
