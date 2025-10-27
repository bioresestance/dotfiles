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

    # Hardware modules
    ../../Modules/Hardware/Audio
    ../../Modules/Hardware/Networking
    ../../Modules/Hardware/GPU/Hybrid

    # Desktop environment
    ../../Modules/Desktop/Plasma

    # Services
    ../../Modules/Services/Virtualization

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
  ];
  boot.blacklistedKernelModules = [ "nouveau" ];

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

  # Optional: Uncomment to enable CIFS network mounts
  # fileSystems."/mnt/Media" = {
  #   device = "//truenas.local/Media";
  #   fsType = "cifs";
  #   options = [
  #     "credentials=/home/aaron/.dotfiles/smb-credentials"
  #     "x-systemd.automount"
  #     "noauto"
  #   ];
  # };

  # fileSystems."/mnt/Homes" = {
  #   device = "//192.168.69.57/Homes";
  #   fsType = "cifs";
  #   options = [
  #     "credentials=/home/aaron/.dotfiles/smb-credentials"
  #     "x-systemd.automount"
  #     "rw"
  #     "users"
  #   ];
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
