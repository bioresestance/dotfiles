# Bromma-Laptop module selection and host-wide choices.
# Device networking and boot tuning are in sibling files.

{
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./stability.nix
    ./networking.nix

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
    ../../Modules/Applications/ThreeDPrinting
    ../../Modules/Applications/Tailscale

    # Users
    ../../Modules/Users/aaron
  ];

  # Enable hardware modules
  module.hardware.audio.enable = true;
  module.hardware.networking = {
    enable = true;
    hostName = "Bromma-Laptop";
    bluetooth.enable = true;
    mt7925FirmwareUpdate.enable = true; # Use latest upstream mt7925 WiFi firmware
    useIwd = true; # Use iwd instead of wpa_supplicant - more stable with mt76 drivers
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

  # Enable applications
  module.apps.development.enable = true;
  module.apps.gaming.enable = true;
  module.apps.security = {
    enable = true;
    polkitPolicyOwners = [ "aaron" ];
  };
  module.apps.threeDPrinting.enable = true;
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
