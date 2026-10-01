# Maintenance Notes

This file tracks work that remains useful for this single-host configuration. The
[README](README.md) covers setup and commands; [MODULES.md](MODULES.md) covers
module layout and options.

## Open items

- **SMB credentials:** `smb-credentials` is ignored by Git, but is still a
  plaintext file inside the checkout. Move it to a root-owned location outside
  the repository, or adopt an encrypted secret solution when that workflow is
  worth maintaining. Update `module.services.network-mounts.credentialsFile`
  when moving it.
- **Temporary NFS mount:** `Systems/Bromma-Laptop/networking.nix` still
  contains a test mount at `/mnt/nfs-test/nfs-media`. Remove its filesystem
  entry and tmpfiles rule once the experiment is complete.
- **Wallpaper assets:** `Themes/Wallpapers` contains large images with
  inconsistent filenames. Audit which ones are used before renaming or removing
  them.
- **Additional hosts:** If another machine is added, extract only the settings
  it actually shares with Bromma-Laptop into reusable modules. Keep machine
  tuning in each host directory.

## Working conventions

- Reusable NixOS modules live in `Modules/`; machine-specific settings live
  in `Systems/<host>/`; Home Manager modules and their source files live in
  `Users/<user>/`.
- Use PascalCase directory names for reusable modules and lower camel case for
  module option names (for example, `ThreeDPrinting` and
  `module.apps.threeDPrinting`). Existing option names should only change with
  a deliberate migration of their callers.
- Run `nix run .#check-format` and `nix flake check` before applying a
  system or home configuration.
