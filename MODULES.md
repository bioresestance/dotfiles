# Module Organization Guide

This document describes the organization of the modular NixOS configuration structure.

## Directory Structure

```
Modules/
├── Common/                    # Base configuration (timezone, locale, flakes)
│   └── Printing/             # CUPS printing support
├── System/                   # System-level configuration
│   └── Utilities/            # Core system utilities and tools
├── Hardware/                 # Hardware-specific modules
│   ├── Audio/                # PipeWire audio configuration
│   ├── Networking/           # NetworkManager and Bluetooth
│   └── GPU/
│       ├── Nvidia/           # (Legacy) NVIDIA-only configuration
│       └── Hybrid/           # NVIDIA + AMD hybrid GPU setup
├── Desktop/                  # Desktop environments
│   └── Plasma/               # KDE Plasma 6 with SDDM
├── Services/                 # System services
│   ├── Virtualization/       # Docker and containerization
│   └── NetworkMounts/        # CIFS/SMB network shares
├── Applications/             # Application modules
│   ├── Development/          # IDEs and development tools
│   ├── Gaming/               # Steam and gaming support
│   ├── Security/             # 1Password
│   ├── 3DPrinting/          # 3D printing software
│   └── Tailscale/           # VPN service
└── Users/                    # User account definitions
    └── aaron/                # User account configuration
```

## Module Pattern

All modules follow the NixOS module pattern with options:

```nix
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.module.<category>.<name>;
in
{
  options = {
    module.<category>.<name>.enable = mkOption {
      description = "Enable <name> module.";
      default = false;  # or true for common modules
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    # Module configuration here
  };
}
```

## Module Categories

### `module.hardware.*`
Hardware-related configuration (audio, networking, GPUs, etc.)

### `module.desktop.*`
Desktop environment configuration

### `module.services.*`
System services (virtualization, etc.)

### `module.apps.*`
Application bundles and software

### `module.system.*`
Core system utilities and configuration

## Usage in System Configuration

Enable modules in your system's `configuration.nix`:

```nix
{
  imports = [
    ./hardware-configuration.nix
    ../../Modules/Common
    ../../Modules/System/Utilities
    ../../Modules/Hardware/Audio
    # ... other modules
  ];

  # Enable modules with options
  module.hardware.audio.enable = true;
  
  module.hardware.networking = {
    enable = true;
    hostName = "my-hostname";
    bluetooth.enable = true;
  };

  module.desktop.plasma = {
    enable = true;
    autoLogin = {
      enable = true;
      user = "username";
    };
  };
  
  # ... other module configurations
}
```

## System vs Home-Manager Packages

### System Packages (`environment.systemPackages`)
- Core system tools and utilities
- Hardware drivers and firmware
- System-level services and daemons
- Development toolchains and compilers
- System administration tools

### Home-Manager Packages (`home.packages`)
- Desktop applications (browsers, office, media players)
- User-specific GUI applications
- Personal productivity tools
- Theme and appearance packages

## Adding a New System

To add a new system configuration:

1. Create a new directory under `Systems/` (e.g., `Systems/Desktop-PC/`)
2. Copy `hardware-configuration.nix` from the new system
3. Create a `configuration.nix` importing the appropriate modules
4. Configure module options specific to that system
5. Add the system to `flake.nix` under `nixosConfigurations`

Example:

```nix
# Systems/Desktop-PC/configuration.nix
{
  imports = [
    ./hardware-configuration.nix
    ../../Modules/Common
    ../../Modules/System/Utilities
    ../../Modules/Desktop/Plasma
    # ... modules for this system
  ];

  # Configure modules for this specific system
  module.hardware.networking.hostName = "Desktop-PC";
  # ...
}
```

## Module Guidelines

1. **Keep modules focused**: Each module should handle a specific aspect or feature set
2. **Use sensible defaults**: Set `default = true` for common/essential features
3. **Make it configurable**: Expose key settings as options when appropriate
4. **Document options**: Use clear descriptions for all options
5. **Group related settings**: Don't create a 1-to-1 module per package unless it makes sense
6. **Test on rebuild**: Always test with `sudo nixos-rebuild switch --flake` after changes

## Network Mounts (CIFS/SMB)

The NetworkMounts module provides a declarative way to configure CIFS/SMB network shares:

```nix
module.services.network-mounts = {
  enable = true;
  credentialsFile = "/home/aaron/.dotfiles/smb-credentials";  # Default
  shares = [
    {
      mountPoint = "/mnt/Media";
      device = "//server.local/Media";
      # Optional: custom mount options (defaults provided)
    }
    {
      mountPoint = "/mnt/Backup";
      device = "//nas/Backup";
      options = [
        "x-systemd.automount"
        "x-systemd.idle-timeout=60"
        "rw"
      ];
    }
  ];
};
```

**Features:**
- Automatic mount point creation
- Systemd automounting (mounts on access, unmounts after idle timeout)
- Proper permissions (uid=1000, gid=100, with configurable file/dir modes)
- Credentials file support for security
- Short timeouts to prevent boot hangs if server is unreachable

**Credentials file format** (`smb-credentials`):
```
username=myuser
password=mypassword
```

## Rebuilding

```bash
# System configuration
sudo nixos-rebuild switch --flake /home/aaron/.dotfiles

# Home-manager configuration
home-manager switch --flake /home/aaron/.dotfiles

# Or use the aliases
nix-rebuild       # for system
home-rebuild      # for home-manager
```
