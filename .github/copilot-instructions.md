# Repository guidance

This is a Nix flake for one NixOS host (`Bromma-Laptop`) and one standalone
Home Manager configuration (`aaron`). Read [README.md](../README.md) for
setup and [MODULES.md](../MODULES.md) for module options.

## Where changes belong

- `flake.nix`: inputs, formatter apps, and system/home outputs.
- `Systems/Bromma-Laptop/configuration.nix`: imports and enabled features.
- `Systems/Bromma-Laptop/networking.nix`: host mounts, dock profile, and network device rules.
- `Systems/Bromma-Laptop/stability.nix`: host boot, kernel, and systemd tuning.
- `Modules/`: reusable NixOS modules. Import each feature module in the host configuration and enable its option there.
- `Users/aaron/home.nix`: imports Home Manager modules. Edit the relevant file in `Users/aaron/modules/` for user settings.
- `Users/aaron/modules/desktop/` and `editors/`: source files for larger themes, scripts, and VS Code settings.

Use PascalCase module directory names and lower camel case for new option
names. `Modules/Applications/ThreeDPrinting` declares
`module.apps.threeDPrinting`. Preserve existing option names unless all
callers are intentionally migrated.

Keep host-specific device and stability settings in the host directory.
Move them into reusable modules when another host actually shares them.
Keep application script bodies and large settings maps in separate source
files where they are easier to edit.

## Checks

Run `nix run .#check-format` and `nix flake check` before applying changes.
`nix run .#format` formats the Nix files selected by `scripts/format.sh`.
CI and the pre-commit hook use the same check-only path. The hook does not
re-stage changes.

For a system change, test with
`sudo nixos-rebuild test --flake .#Bromma-Laptop` before switching. For a
Home Manager change, use `home-manager build --flake .#aaron` before switching.
