# Quick Reference

Run these from the repository root unless a path is shown.

## Rebuild

```bash
sudo nixos-rebuild test --flake .#Bromma-Laptop
sudo nixos-rebuild switch --flake .#Bromma-Laptop
home-manager switch --flake .#aaron
```

The `nix-rebuild` and `home-rebuild` shell aliases are defined in the Home
Manager shell module.

## Check and format

```bash
nix flake check
nix run .#check-format
nix run .#format
```

`scripts/format.sh [--check]` is the shared implementation used by both flake
apps and CI. The pre-commit hook checks formatting without changing staged files.

## Update and diagnose

```bash
nix flake update
nix flake check --show-trace
systemctl status nix-flake-auto-update.service
journalctl -u nix-flake-auto-update.service -n 200
systemctl status mnt-Media.mount
```

## Where to edit

- `flake.nix`: flake inputs and system/home outputs
- `Systems/Bromma-Laptop/configuration.nix`: enabled modules and host choices
- `Systems/Bromma-Laptop/networking.nix`: mounts, dock network profile, and network hardware rules
- `Systems/Bromma-Laptop/stability.nix`: boot, kernel, and systemd tuning
- `Modules/`: reusable NixOS modules
- `Users/aaron/modules/`: Home Manager configuration and editable source files
- `MODULES.md`: module layout and options
- `IMPROVEMENTS.md`: remaining maintenance work

See [README.md](README.md) for initial setup and [MODULES.md](MODULES.md)
for module details.
