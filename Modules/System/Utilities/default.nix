{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.module.system.utilities;
in
{
  options = {
    module.system.utilities.enable = mkOption {
      description = "Enable essential system utilities.";
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      # Core System Tools
      linux-firmware
      libusb1
      pciutils
      lshw
      gparted
      distrobox
      libnotify

      # Text Editors
      vim
      neovim

      # Terminal Tools
      kitty
      tmux
      bat
      tldr

      # System Monitoring and Management
      powertop
      htop
      nvtopPackages.full

      # Hardware Management
      gnome-firmware
      asusctl
      fwupd

      # Network Tools
      wget
      dig
      nmap
      sshpass
      cifs-utils

      # File System and Storage
      xorg.xrandr

      # Scanning and Imaging
      simple-scan
      xsane
      naps2

      # Python Package Manager
      uv

      # Audio Control
      pavucontrol

      # GTK Libraries (for app compatibility)
      gtk3
      gtk4
    ];

    # Enable Zsh system-wide
    programs.zsh.enable = true;

    # Enable Firefox
    programs.firefox.enable = true;

    # Enable firmware updates
    services.fwupd.enable = true;

    # Enable ASUS hardware control
    services.asusd.enable = true;

    # Enable all firmware
    hardware.enableAllFirmware = true;

    # Enable Thunderbolt support
    services.hardware.bolt.enable = true;

    # Enable power management
    powerManagement.enable = true;

    # Enable nix-ld for dynamic linking
    programs.nix-ld.enable = true;
  };
}
