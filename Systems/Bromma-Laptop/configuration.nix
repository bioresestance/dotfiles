# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Common modules
    ../../Modules/Common
    ../../Modules/System/Utilities
    ../../Modules/System/AutoUpdate

    # Hardware modules
    ../../Modules/Hardware/Audio
    ../../Modules/Hardware/Networking
    ../../Modules/Hardware/GPU/Hybrid

    # Desktop environment
    ../../Modules/Desktop/Plasma

    # Services
    ../../Modules/Services/Virtualization
    ../../Modules/Services/NetworkMounts

    # Applications
    ../../Modules/Applications/Development
    ../../Modules/Applications/Gaming
    ../../Modules/Applications/Security
    ../../Modules/Applications/3DPrinting
    ../../Modules/Applications/Tailscale

    # Users
    ../../Modules/Users/aaron
  ];

  # Bootloader configuration
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
    "amdgpu.exp_hw_support=1" # For experimental GPU support, if applicable
    "usbcore.authorized_default=0" # Start USB devices in blocked state so udev can selectively re-authorize
  ];
  boot.blacklistedKernelModules = [
    "nouveau"
    "r8152" # Realtek USB NIC driver that can wedge xHCI controllers
    "r8152-cfgselector"
  ];
  # Enable Thunderbolt kernel driver
  boot.kernelModules = [ "thunderbolt" ];

  #systemd configurations
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "30s";
  };

  # Improve shutdown behavior for user services
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=15s
  '';

  # Enable hardware modules
  module.hardware.audio.enable = true;
  module.hardware.networking = {
    enable = true;
    hostName = "Bromma-Laptop";
    bluetooth.enable = true;
  };
  module.hardware.gpu.hybrid = {
    enable = true;
    nvidiaBusId = "PCI:100:0:0";
    amdgpuBusId = "PCI:101:0:0";
  };

  # Enable desktop environment
  module.desktop.plasma = {
    enable = true;
    autoLogin = {
      enable = true;
      user = "aaron";
    };
  };

  # Enable services
  module.services.virtualization.enable = true;
  module.services.network-mounts = {
    enable = true;
    shares = [
      {
        mountPoint = "/mnt/Media";
        device = "//192.168.69.57/Media";
      }
      {
        mountPoint = "/mnt/Homes";
        device = "//192.168.69.57/Homes";
      }
    ];
  };

  # Ensure Thunderbolt is properly configured
  services.hardware.bolt.enable = true;

  # Keep the Plugable dock's Realtek RTL8156 NIC from binding to the generic
  # CDC NCM stack (which currently wedges the laptop's xHCI controller). Every
  # USB device now starts unauthorized (via usbcore.authorized_default=0) and
  # this rule re-enables everything except the problematic NIC.
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156", GOTO="rtl8156_block"
    SUBSYSTEM=="usb", TEST=="authorized", ATTR{authorized}="1"
    GOTO="rtl8156_end"
    LABEL="rtl8156_block"
    SUBSYSTEM=="usb", TEST=="authorized", ATTR{authorized}="0"
    LABEL="rtl8156_end"
  '';

  # Enable applications
  module.apps.development.enable = true;
  module.apps.gaming.enable = true;
  module.apps.security = {
    enable = true;
    polkitPolicyOwners = [ "aaron" ];
  };
  module.apps.ThreeDPrinting.enable = true;
  module.apps.tailscale.enable = true;

  # System utilities (enabled by default)
  module.system.utilities.enable = true;

  module.system.autoUpdate = {
    enable = true;
    repoPath = "/home/aaron/.dotfiles";
    repoUser = "aaron";
    nixosTargets = [ "Bromma-Laptop" ];
    homeManagerTargets = [
      {
        user = "aaron";
        flakeAttr = "aaron";
      }
    ];
    notification = {
      command = "${pkgs.libnotify}/bin/notify-send";
      appName = "Nix Auto Update";
      icon = "preferences-system-updates";
      timeoutMs = 10000;
      extraArgs = [ "--hint=int:transient:1" ];
    };
    git = {
      commitMessagePrefix = "Auto-update";
      enablePush = true;
      remote = "origin";
      branch = "main";
    };
    timer = {
      onCalendar = "daily";
      onBootSec = "5min";
      randomizedDelaySec = "30min";
      persistent = true;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
