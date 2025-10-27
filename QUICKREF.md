# Quick Reference - NixOS Dotfiles

## 🚀 Essential Commands

### System Management
```bash
nix-rebuild              # Rebuild system (alias)
sudo nixos-rebuild switch --flake ~/.dotfiles
```

### Home Manager
```bash
home-rebuild             # Rebuild home (alias)
home-manager switch --flake ~/.dotfiles
```

### Formatting
```bash
nix run .#format         # Format all Nix files
nix run .#check-format   # Check formatting
./scripts/format.sh      # Alternative format script
```

### Updates
```bash
nix flake update         # Update all inputs
nix flake check          # Validate flake
```

### Cleanup
```bash
sudo nix-collect-garbage -d              # Clean old generations
nix-store --optimize                     # Optimize store
```

## 📦 Available Apps

```bash
nix run .#format         # Format all Nix files in repo
nix run .#check-format   # Check formatting without changes
```

## 🔧 Module Quick Reference

Enable in `configuration.nix`:

```nix
# Hardware
module.hardware.audio.enable = true;
module.hardware.networking.enable = true;
module.hardware.gpu.hybrid.enable = true;

# Desktop
module.desktop.plasma.enable = true;

# Services
module.services.virtualization.enable = true;
module.services.network-mounts.enable = true;

# Applications
module.apps.development.enable = true;
module.apps.gaming.enable = true;
module.apps.security.enable = true;
```

## 🐛 Troubleshooting

```bash
# Check system status
systemctl status <service>
journalctl -xe

# Test configuration
sudo nixos-rebuild test --flake ~/.dotfiles

# Debug network mounts
./debug-smb.sh

# View errors
nix flake check --show-trace
```

## 📁 Important Files

- `flake.nix` - Flake entry point
- `Systems/<hostname>/configuration.nix` - System config
- `Users/<user>/home.nix` - Home-manager config
- `MODULES.md` - Module documentation
- `IMPROVEMENTS.md` - Planned improvements

## 🔗 Quick Links

- [Full README](./README.md)
- [Module Docs](./MODULES.md)
- [Improvements](./IMPROVEMENTS.md)
