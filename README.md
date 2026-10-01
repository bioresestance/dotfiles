# NixOS Dotfiles Configuration

A modular, flake-based NixOS configuration with home-manager integration.

## 🚀 Quick Start

### Prerequisites
- NixOS installed with flakes enabled
- Git configured

### Initial Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/bioresestance/dotfiles.git ~/.dotfiles
   cd ~/.dotfiles
   ```

2. **Review and customize:**
   - Edit `Systems/Bromma-Laptop/configuration.nix` (or create your own system)
   - Update `Users/aaron/home.nix` with your preferences
   - Modify `smb-credentials` if using network mounts

3. **Apply system configuration:**
   ```bash
   sudo nixos-rebuild switch --flake ~/.dotfiles
   ```

4. **Apply home-manager configuration:**
   ```bash
   home-manager switch --flake ~/.dotfiles
   ```

## 📁 Repository Structure

```
.
├── flake.nix                 # Flake entry point
├── flake.lock               # Locked dependency versions
├── MODULES.md               # Module system documentation
├── IMPROVEMENTS.md          # Planned improvements
│
├── Systems/                 # System configurations
│   └── Bromma-Laptop/
│       ├── configuration.nix
│       └── hardware-configuration.nix
│
├── Users/                   # Home-manager configurations
│   └── aaron/
│       └── home.nix
│
├── Modules/                 # Reusable modules
│   ├── Common/             # Base configuration
│   ├── System/             # System utilities
│   ├── Hardware/           # Hardware modules (Audio, GPU, Networking)
│   ├── Desktop/            # Desktop environments (Plasma)
│   ├── Services/           # Services (Virtualization, NetworkMounts)
│   ├── Applications/       # App bundles (Development, Gaming, etc.)
│   └── Users/              # User account definitions
│
└── Themes/                 # Wallpapers and visual assets
```

## 🔧 Common Commands

### System Management

```bash
# Rebuild system configuration
sudo nixos-rebuild switch --flake ~/.dotfiles
# Or use the alias:
nix-rebuild

# Rebuild without applying changes (test mode)
sudo nixos-rebuild test --flake ~/.dotfiles

# Build and activate on next boot
sudo nixos-rebuild boot --flake ~/.dotfiles

# Check what would change
nixos-rebuild dry-build --flake ~/.dotfiles
```

### Home Manager

```bash
# Apply home-manager configuration
home-manager switch --flake ~/.dotfiles
# Or use the alias:
home-rebuild

# See what would change
home-manager build --flake ~/.dotfiles
```

### Updates

```bash
# Update all flake inputs (nixpkgs, home-manager, etc.)
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Check flake for errors
nix flake check
```

### Cleanup

```bash
# Remove old generations and free space
sudo nix-collect-garbage -d

# Remove old generations older than 7 days
sudo nix-collect-garbage --delete-older-than 7d

# Optimize nix store
nix-store --optimize
```

### Formatting

```bash
# Format all Nix files in the repository
nix run .#format

# Check formatting without modifying files
nix run .#check-format

# Format specific files
nixfmt path/to/file.nix

# Format using script (alternative)
./scripts/format.sh
```

## 🔄 Automated Flake Updates

- Enable `module.system.autoUpdate` in your system configuration to automatically run `nix flake update`, `nixos-rebuild switch`, and the configured home-manager switches once per day (first boot of the day, thanks to `Persistent=true`).
- The module drops a script at `nix-flake-auto-update.service`/`.timer`, sends desktop notifications via `notify-send` by default, and rolls back `flake.lock` if a rebuild fails.
- Git commits + pushes are handled automatically when the lockfile changes; `openssh` is bundled so Git can invoke your repo user's SSH remotes, and push failures are reported in the notification but do not abort the update.
- Key knobs: `repoPath`, `repoUser` (run flake/git as the repo owner), `nixosTargets`, `homeManagerTargets`, `notification.user/command/icon` (run the notify command inside that user's session bus), `git.remote/branch`, `git.safeDirectories`, dirty-tree enforcement (`git.allowDirty`), and `timer` cadence. See `MODULES.md` for a complete example.
- Check status/logs with:

```bash
systemctl status nix-flake-auto-update.service
journalctl -u nix-flake-auto-update.service -n 200
```

## 🏗️ Adding a New System

1. **Create system directory:**
   ```bash
   mkdir -p Systems/NewSystem
   ```

2. **Copy hardware configuration:**
   ```bash
   cp /etc/nixos/hardware-configuration.nix Systems/NewSystem/
   ```

3. **Create configuration.nix:**
   ```nix
   {
     imports = [
       ./hardware-configuration.nix
       ../../Modules/Common
       # Add modules you need
     ];

     module.hardware.networking.hostName = "NewSystem";
     # Configure modules...
   }
   ```

4. **Add to flake.nix:**
   ```nix
   nixosConfigurations.NewSystem = lib.nixosSystem {
     inherit system;
     modules = [ ./Systems/NewSystem/configuration.nix ];
   };
   ```

5. **Build and activate:**
   ```bash
   sudo nixos-rebuild switch --flake ~/.dotfiles#NewSystem
   ```

## 📦 Available Modules

See [MODULES.md](MODULES.md) for detailed documentation.

Quick reference:
- **Hardware:** audio, networking, gpu.hybrid
- **Desktop:** plasma
- **Services:** virtualization, network-mounts
- **Applications:** development (VS Code, Clang, Python 3.13 bundle w/ proxmoxer & pytest, Hugo, Ansible), gaming, security, ThreeDPrinting, tailscale
- **System:** utilities, autoUpdate (automated flake updater)

## 🔒 Secrets Management

⚠️ **Important:** The `smb-credentials` file is git-ignored but contains plaintext passwords.

**Recommendations:**
- Use `sops-nix` or `agenix` for encrypted secrets management
- See [IMPROVEMENTS.md](IMPROVEMENTS.md) for implementation guide

## 🐛 Troubleshooting

### Configuration doesn't apply
```bash
nix flake check  # Check for syntax errors
sudo nixos-rebuild switch --flake ~/.dotfiles --show-trace  # Verbose
```

### Boot fails after update
- Select previous generation from bootloader menu
- Investigate with `journalctl -xb`

### Network mounts not working
```bash
systemctl status mnt-Media.mount  # Check status
journalctl -u mnt-Media.mount     # View logs
```

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Module Documentation](./MODULES.md)
- [Planned Improvements](./IMPROVEMENTS.md)

## 📄 License

Personal configuration - use at your own discretion.
