# NixOS Dotfiles - Improvement Recommendations

## 🎯 High Priority Improvements

### 1. **Secrets Management** 🔒
**Current Issue:** `smb-credentials` contains plaintext passwords in git
**Recommendation:** Use `sops-nix` or `agenix` for secrets management

<function_calls>
<invoke name="create_file">
<parameter name="content"># NixOS Dotfiles - Improvement Recommendations

## 🎯 High Priority Improvements

### 1. **Secrets Management** 🔒
**Current Issue:** `smb-credentials` contains plaintext passwords in git (even though .gitignored, still risky)

**Recommendation:** Use `sops-nix` or `agenix` for encrypted secrets

**Implementation:**
```nix
# Add to flake.nix inputs:
inputs.sops-nix.url = "github:Mic92/sops-nix";

# In modules, reference secrets:
age.secrets.smb-credentials = {
  file = ./secrets/smb-credentials.age;
  owner = "root";
  group = "root";
};

# Then use: config.age.secrets.smb-credentials.path
```

**Benefit:** Encrypted secrets in git, safe to commit

---

### 2. **Improve README.md** 📚
**Current Issue:** Minimal documentation, only shows garbage collection

**Recommendation:** Comprehensive README with:
- Repository overview and structure
- Quick start guide
- How to add a new system
- Common commands (rebuild, update, rollback)
- Troubleshooting guide
- Link to MODULES.md

---

### 3. **Remove Empty/Legacy Modules** 🧹
**Current Issue:** `Modules/Hardware/GPU/Nvidia/default.nix` is empty and unused

**Actions:**
- Delete the empty Nvidia module (using Hybrid now)
- Clean up any other unused files
- Add a comment in copilot-instructions.md about preferring Hybrid over standalone GPU modules

---

### 4. **Add Formatter and CI/CD** 🤖
**Status:** ✅ IMPLEMENTED

**What was done:**
- Added `formatter` to flake.nix using nixfmt-rfc-style
- Created `nix run .#format` app for easy formatting
- Created `nix run .#check-format` app for validation
- Added GitHub Actions workflow for CI/CD
- Created `scripts/format.sh` helper script

**Usage:**
```bash
# Format all files
nix run .#format

# Check formatting
nix run .#check-format
```

**Note:** Don't use `nix fmt` without arguments as it can hang when processing the entire tree.

---

### 5. **Pre-commit Hooks** 🪝
**Recommendation:** Auto-generate module options documentation

Create `docs/` directory with generated markdown from module options.

---

### 6. **Template System for New Systems** 🏗️
**Recommendation:** Create a template directory for quick system setup

```
Templates/
├── system-template/
│   ├── configuration.nix
│   └── hardware-configuration.nix (placeholder)
└── README.md  # Instructions on using templates
```

Script to copy template:
```bash
#!/usr/bin/env bash
# scripts/new-system.sh
SYSTEM_NAME=$1
cp -r Templates/system-template Systems/$SYSTEM_NAME
sed -i "s/HOSTNAME/$SYSTEM_NAME/g" Systems/$SYSTEM_NAME/configuration.nix
```

---

### 7. **Pre-commit Hooks** 🪝
**Recommendation:** Add pre-commit hooks for formatting and validation

```nix
# Add to flake.nix inputs:
inputs.pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

# In outputs:
checks.${system}.pre-commit = pre-commit-hooks.lib.${system}.run {
  src = ./.;
  hooks = {
    nixfmt.enable = true;
    statix.enable = true;  # Linter
    deadnix.enable = true; # Find unused code
  };
};
```

---

### 8. **System-Specific Overlays** 🎨
**Recommendation:** Add a `Overlays/` directory for package customizations

Useful for:
- Patching packages
- Adding custom versions
- System-specific package modifications

---

### 9. **Testing Framework** 🧪
**Recommendation:** Add NixOS tests for critical functionality

```nix
# Tests/basic-system.nix
import <nixpkgs/nixos/tests/make-test-python.nix> {
  name = "basic-system-test";
  nodes.machine = { ... }: {
    imports = [ ../Systems/Bromma-Laptop/configuration.nix ];
  };
  testScript = ''
    machine.wait_for_unit("default.target")
    machine.succeed("systemctl status sddm")
  '';
}
```

---

### 10. **Backup/Restore Scripts** 💾
**Recommendation:** Add scripts for backing up important configs

```bash
# scripts/backup.sh
#!/usr/bin/env bash
# Backup important files before rebuild
tar -czf backups/backup-$(date +%Y%m%d-%H%M%S).tar.gz \
  /etc/nixos/hardware-configuration.nix \
  ~/.config/important-app-configs
```

---

## 💡 Nice-to-Have Improvements

### 11. **Hardware Profiles Library** 🖥️
Create reusable hardware profiles:
```
Modules/Hardware/Profiles/
├── laptop-power-management.nix
├── nvidia-optimus.nix
├── bluetooth-audio.nix
└── thunderbolt.nix
```

---

### 12. **Module Dependency Visualization** 📊
**Recommendation:** Generate a dependency graph of modules

Use `nix-tree` or create a custom script to visualize module relationships.

---

### 13. **Changelog/Version Management** 📝
**Recommendation:** Keep a CHANGELOG.md for tracking changes

Use conventional commits and automated changelog generation.

---

### 14. **Better Home-Manager Integration** 🏠
**Recommendation:** Use home-manager as NixOS module instead of standalone

Benefits:
- Single rebuild command
- Better integration
- Shared options between system and home

```nix
# In flake.nix:
nixosConfigurations.Bromma-Laptop = lib.nixosSystem {
  modules = [
    ./Systems/Bromma-Laptop/configuration.nix
    home-manager.nixosModules.home-manager
    {
      home-manager.users.aaron = import ./Users/aaron/home.nix;
    }
  ];
};
```

---

### 15. **Performance Optimization Module** ⚡
Create a module for performance tuning:
- SSD optimization (TRIM, noatime)
- Kernel parameters for performance
- Swap configuration
- Tmpfs for /tmp

---

### 16. **Monitoring and Metrics** 📈
**Recommendation:** Add optional monitoring modules
- Prometheus exporters
- Grafana dashboard configs
- System health checks

---

### 17. **Multi-User Support** 👥
Enhance user module system:
```
Users/
├── shared/          # Shared home-manager configs
├── aaron/
└── template/        # Template for new users
```

---

### 18. **Network Configuration Module** 🌐
Expand networking beyond basics:
- VPN profiles
- WiFi networks (using `networking.wireless.networks`)
- Firewall rules
- Custom DNS

---

### 19. **Container/VM Definitions** 🐳
Add declarative containers:
```
Containers/
├── development-env.nix
├── test-server.nix
└── database.nix
```

---

### 20. **Automated Update Script** 🔄
**Recommendation:** Script to safely update and test:

```bash
#!/usr/bin/env bash
# scripts/safe-update.sh
nix flake update
nix build .#nixosConfigurations.Bromma-Laptop.config.system.build.toplevel
if [ $? -eq 0 ]; then
  sudo nixos-rebuild boot --flake .
  echo "New config will activate on next boot"
else
  echo "Build failed, not applying"
  exit 1
fi
```

---

## 🎨 Quality of Life Improvements

### 21. **Shell Completions** 
Add completions for custom scripts and commands.

### 22. **Direnv Integration**
Add `.envrc` for automatic Nix shell activation:
```bash
use flake
```

### 23. **Better Git Hooks**
- Prevent commits with syntax errors
- Auto-format on commit
- Run `nix flake check` before push

### 24. **Module Status Dashboard**
Create a script that shows:
- Which modules are enabled
- System resources usage
- Last update time
- Available updates

---

## 🏆 Implementation Priority

**Week 1:**
1. ✅ Secrets management (sops-nix)
2. ✅ Improve README
3. ✅ Remove empty modules
4. ✅ Add formatter

**Week 2:**
5. ✅ CI/CD with GitHub Actions
6. ✅ Pre-commit hooks
7. ✅ Testing framework basics

**Week 3:**
8. ✅ Template system
9. ✅ Backup scripts
10. ✅ Better home-manager integration

**Ongoing:**
- Module documentation
- Hardware profiles
- Performance tuning

---

## 📚 Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [sops-nix](https://github.com/Mic92/sops-nix)
- [NixOS Flake Examples](https://github.com/misterio77/nix-starter-configs)

---

*This document provides a roadmap for improving your NixOS configuration repository. Implement changes gradually and test thoroughly!*
