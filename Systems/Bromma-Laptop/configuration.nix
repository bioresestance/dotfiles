# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{
  pkgs,
  ...
}:

let
  dockEthernetProfile = pkgs.writeText "dock-ethernet.nmconnection" ''
    [connection]
    id=Dock Ethernet
    uuid=21917c9e-63aa-4a07-9a37-79fba399a097
    type=ethernet
    autoconnect=true
    permissions=

    [ethernet]
    mac-address=8C:AE:4C:BE:04:75

    [ipv4]
    method=auto

    [ipv6]
    addr-gen-mode=eui64
    method=auto

    [proxy]
  '';
in
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

    # MT7925 WiFi stability fixes - disable power saving to prevent driver deadlocks
    "mt7925e.disable_aspm=1"
    "mt76.disable_power_save=1"

    # System stability - enable watchdog and panic handling
    "panic=10" # Reboot 10 seconds after kernel panic
    "kernel.hung_task_panic=1" # Panic (and thus reboot) on hung tasks
    "kernel.hung_task_timeout_secs=300" # Wait 5 minutes before declaring hung

    # Disable PSR (Panel Self Refresh) which can cause display/system hangs on some AMD iGPUs
    "amdgpu.dcdebugmask=0x10"
  ];
  boot.blacklistedKernelModules = [
    "nouveau"
  ];
  # Enable Thunderbolt kernel driver
  boot.kernelModules = [ "thunderbolt" ];

  #systemd configurations
  systemd.settings.Manager = {
    DefaultTimeoutStopSec = "30s";
    # Force shutdown even if services don't stop cleanly
    DefaultTimeoutAbortSec = "30s";
    # Watchdog configuration for system manager
    RuntimeWatchdogSec = "30s";
    RebootWatchdogSec = "5min";
    KExecWatchdogSec = "5min";
  };

  # Improve shutdown behavior for user services
  systemd.user.extraConfig = ''
    DefaultTimeoutStopSec=15s
    DefaultTimeoutAbortSec=15s
  '';

  # Enable systemd-oomd for better handling of memory pressure situations
  systemd.oomd.enable = true;

  # Kernel sysctl settings for stability
  boot.kernel.sysctl = {
    # Hung task detection - panic on hung tasks to force reboot instead of permanent freeze
    "kernel.hung_task_panic" = 1;
    "kernel.hung_task_timeout_secs" = 300; # 5 minutes

    # VM/memory tuning to reduce pressure that can trigger driver issues
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;

    # Network stability tuning
    "net.core.netdev_max_backlog" = 4096;
  };

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

  # Force Realtek USB NICs (including RTL8156) into the vendor-specific
  # configuration so the r8152 driver binds instead of the generic CDC stack.
  services.udev.extraRules = ''
    ACTION!="add", GOTO="usb_realtek_net_end"
    SUBSYSTEM!="usb", GOTO="usb_realtek_net_end"
    ENV{DEVTYPE}!="usb_device", GOTO="usb_realtek_net_end"

    ENV{REALTEK_MODE1}="1"
    ENV{REALTEK_MODE2}="3"

    # Realtek OEM adapters
    ATTR{idVendor}=="0bda", ATTR{idProduct}=="815[2,3,5,6]", ATTR{bConfigurationValue}!="$env{REALTEK_MODE1}", ATTR{bConfigurationValue}="$env{REALTEK_MODE1}"
    ATTR{idVendor}=="0bda", ATTR{idProduct}=="8053", ATTR{bcdDevice}=="e???", ATTR{bConfigurationValue}!="$env{REALTEK_MODE2}", ATTR{bConfigurationValue}="$env{REALTEK_MODE2}"

    LABEL="usb_realtek_net_end"
  '';

  # Provide a persistent NetworkManager profile so the dock NIC keeps
  # autoconnecting even if the kernel renames the interface after USB resets.
  environment.etc."NetworkManager/system-connections/dock-ethernet.nmconnection" = {
    source = dockEthernetProfile;
    mode = "0600";
  };

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
